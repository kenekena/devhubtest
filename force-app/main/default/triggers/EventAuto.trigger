trigger EventAuto on Event (
	after insert,
	after update
//	after delete,
//	after undelete,
//	before insert,
//	before update,
//	before delete
){
	// -----------------------------------------------------
	// カスタムメタデータ取得
	// -----------------------------------------------------
	Kyosin7Setting__mdt Kyosin7Setting = [SELECT MasterLabel, EventAuto__c,
																				DailyReport_MidnightStartTime__c, DailyReport_MidnightEndTime__c
																			FROM Kyosin7Setting__mdt];
//System.debug('Kyosin7Setting__mdt　'+Kyosin7Setting.MasterLabel);
//System.debug('EventAuto__c　'+Kyosin7Setting.EventAuto__c);

	// 行動自動処理がTrueの場合処理する
	if(Kyosin7Setting.EventAuto__c == True){
        
		// after insert処理
		if (Trigger.isAfter && Trigger.isInsert) {
System.debug('Event after insert処理　');

			// -----------------------------------------------------
			// 行動OBJデータ取得
			// -----------------------------------------------------
			// 行動レコード取得
			List<Event> EventList = Trigger.new;
			Event Event = EventList.get(0);
			ID EventId = Event.Id;
			Datetime StartDateTime = Event.StartDateTime;
			Datetime EndDateTime = Event.EndDateTime;
			Datetime ActivityDate = Event.ActivityDate;

			// 前日の行動を取得
			Boolean PreviousDayActionNew = Event.PreviousDayAction__c;
			// 関連日報を設定
			ID DailyReportId = Event.DailyReportId__c;
//System.debug('DailyReportId　IN '+DailyReportId);
			// 関連先を設定
			ID WID = Event.WhatId;

            // -------------------------------------------------------------------------------------------------------------------
			// 終日行動がFalesの場合かつ関連日報なしがFalseの場合処理する
			// -------------------------------------------------------------------------------------------------------------------
			if(Event.IsAllDayEvent == False && Event.DailyReportNoConnection__c == False){
                
				// 項目定義
				ID MasterMemberId = null;
				ID OwnId = null;

				// 所有者を設定
				OwnId = Event.OwnerId;
				// 行動の所有者から関連メンバーを取得
				List<MasterMember__c> MasterMemberList = [SELECT Id  FROM MasterMember__c  WHERE UserId__c = :OwnId];

                // -------------------------------------------------------------------------------------------------------------------
                // メンバーマスタが取得できた場合のみ処理する
                // -------------------------------------------------------------------------------------------------------------------
                if(MasterMemberList.size() > 0){
					MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
					MasterMemberId = MasterMemberSLT.Id;

					// 日報識別IDを設定(日付＋関連メンバー)
					String DailyReportIdentificationId = String.valueOf(Event.ActivityDate).left(10) + MasterMemberId;
					// 算出対象の日付を設定
					Date TSDT = Date.valueOf(String.valueOf(Event.ActivityDate).left(10));

					// 前日の行動にチェックがある場合、日付を−１日にする
					if(PreviousDayActionNew == True){
						// 日報識別IDを設定(日付＋関連メンバー)
						DailyReportIdentificationId = String.valueOf(Event.ActivityDate-1).left(10) + MasterMemberId;
						// 算出対象の日付を−１日にする
						TSDT = Date.valueOf(String.valueOf(Event.ActivityDate-1).left(10));
					}
//System.debug('日報識別ID　'+DailyReportIdentificationId);
//System.debug('対象日付　'+TSDT);

					// -----------------------------------------------------
					// 日報IDを取得
					// -----------------------------------------------------    
					// 日報識別IDより日報データを取得
					List<DailyReport__c> DailyReportList = [SELECT Id
																							FROM DailyReport__c  
																							WHERE DailyReportIdentificationId__c = :DailyReportIdentificationId];
					// 日報ID設定
					ID DRID = null;

					// 日報OBJデータあり
					if(DailyReportList.size() > 0){
						// 日報IDを取得
						DailyReport__c DailyReportSLT = DailyReportList.get(0);
						DailyReportId = DailyReportSLT.Id;
					}
                }

                // -------------------------------------------------------------------------------------------------------------------
				// 終日行動がFalesの場合
				// 表示用の開始時間と終了時間を設定
				// -------------------------------------------------------------------------------------------------------------------
				// 開始時間を設定
				String StartDateTimeSTR = '';
				String StartTime= '';
				// 終了時間を設定
				String EndDateTimeSTR = '';
                String EndTime = '';

                if(Event.IsAllDayEvent == False){
					// ----------------------------------------------------------------------------
					// [表示用]開始時間を設定
					// ----------------------------------------------------------------------------
					if(0 <= StartDateTime.minute() && StartDateTime.minute() < 9){
						StartDateTimeSTR = '0'+ String.valueof(StartDateTime.minute());
					}else{
						StartDateTimeSTR = String.valueof(StartDateTime.minute());
					}
					StartTime = String.valueof(StartDateTime.hour()) + ':' + StartDateTimeSTR;

					// ----------------------------------------------------------------------------
					// [表示用]終了時間を設定
					// ----------------------------------------------------------------------------
                    if(0 <= EndDateTime.minute() && EndDateTime.minute() < 9){
						EndDateTimeSTR = '0'+ String.valueof(EndDateTime.minute());
					}else{
						EndDateTimeSTR = String.valueof(EndDateTime.minute());
					}
					EndTime = String.valueof(EndDateTime.hour()) + ':' + EndDateTimeSTR;
					// 日付より終了時間が大きいの場合は、頭に”翌”を付与
					if(ActivityDate.format() < EndDateTime.format()){
						EndTime = '翌' + EndTime;
					}
                }

				// 行動OBJの関連先に値が入っていない場合は、日報IDをひもつける
				if(WID == null){
					WID = DailyReportId;
				}

                // -----------------------------------------------------
				// 行動OBJに日報IDを設定して更新
				// -----------------------------------------------------    
				// 行動OBJ
				List<Event> EventTMP = new List<Event>();

				// 行動OBJの更新データを設定
				EventTMP.add(new Event(
													Id = EventID, 
													WhatId = WID,
													StartTime__c = StartTime, 
													EndTime__c = EndTime, 
													DailyReportId__c = DailyReportId
										)
				); 

				// 行動データ更新登録
 				if (EventTMP.size() > 0) {
//System.debug('行動データ　'+EventTMP);
					try{
						update EventTMP;
					}catch(DmlException e){
						System.debug('行動OBJの更新登録失敗');
						Integer errNum = e.getNumDml();
						for(Integer i = 0; i < errNum; i++){
							EventTMP.get(e.getDmlIndex(i)).addError('行動データ更新時にエラーが発生しました'+e.getDmlMessage(i));
						}
					}
				}
			}
		}
        
		// after update処理
		if (Trigger.isAfter && Trigger.isUpdate) {
System.debug('Event after update処理　');
            
			// -----------------------------------------------------
			// 行動OBJデータ取得
			// -----------------------------------------------------
			// 行動レコード取得
			List<Event> EventList = Trigger.new;
			Event Event = EventList.get(0);
			// IDを設定
			ID EventID = Event.Id;
			// 関連先を設定
			ID WID = Event.WhatId;
			// 関連日報を設定
			ID DailyReportId = Event.DailyReportId__c;
			// 変更後の所有者と前日の行動を取得
			ID OwnerIdNew = Event.OwnerId;
			Boolean PreviousDayActionNew = Event.PreviousDayAction__c;
//System.debug('Event　'+Event);
//System.debug('PreviousDayActionNew　'+PreviousDayActionNew);
//System.debug('DailyReportIdNew　'+DailyReportId);
			Datetime StartDateTime = Event.StartDateTime;
			Datetime EndDateTime = Event.EndDateTime;
			Datetime ActivityDate = Event.ActivityDate;
            
			// 変更前の所有者と前日の行動を取得
			List<Event> EventList_OLD = Trigger.old;
			Event Event_OLD = EventList_OLD.get(0);
			ID OwnerIdOld = Event_OLD.OwnerId;
			Boolean PreviousDayActionOld = Event_OLD.PreviousDayAction__c;
			// 関連日報を設定
			ID DailyReportIdOLD = Event_OLD.DailyReportId__c;
//System.debug('Event_OLD　'+Event_OLD);
//System.debug('PreviousDayActionOld　'+PreviousDayActionOld);
//System.debug('DailyReportIdOld　'+DailyReportIdOLD);
			// 日報ID設定
			ID DRID = null;


			//---------------------------------------------------------------------------
			// 行動の最終更新日が前回と違う場合に処理する（ループ防止）
			//---------------------------------------------------------------------------
			if(Event.LastModifiedDate != Event_OLD.LastModifiedDate){

				// -------------------------------------------------------------------------------------------------------------------
				// メンバーマスタが取得できた場合のみ関連日報IDを設定する
       	        // -------------------------------------------------------------------------------------------------------------------
				// 項目定義
				ID MasterMemberId = null;
				ID OwnId = null;

				// 所有者を設定
				OwnId = Event.OwnerId;
				// 行動の所有者から関連メンバーを取得
				List<MasterMember__c> MasterMemberList = [SELECT Id  FROM MasterMember__c  WHERE UserId__c = :OwnId];

                // メンバーマスタレコードがあっる場合
				if(MasterMemberList.size() > 0){
					MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
					MasterMemberId = MasterMemberSLT.Id;

					// 日報識別IDを設定(日付＋関連メンバー)
					String DailyReportIdentificationId = String.valueOf(Event.ActivityDate).left(10) + MasterMemberId;
					// 算出対象の日付を設定
					Date TSDT = Date.valueOf(String.valueOf(Event.ActivityDate).left(10));

					// 前日の行動にチェックがある場合、日付を−１日にする
					if(PreviousDayActionNew == True){
						// 日報識別IDを設定(日付＋関連メンバー)
						DailyReportIdentificationId = String.valueOf(Event.ActivityDate-1).left(10) + MasterMemberId;
						// 算出対象の日付を−１日にする
						TSDT = Date.valueOf(String.valueOf(Event.ActivityDate-1).left(10));
					}
//System.debug('日報識別ID　'+DailyReportIdentificationId);
//System.debug('対象日付　'+TSDT);

					// -----------------------------------------------------
					// 日報IDを取得
					// -----------------------------------------------------    
					// 日報識別IDより日報データを取得
					List<DailyReport__c> DailyReportList = [SELECT Id
																							FROM DailyReport__c  
																							WHERE DailyReportIdentificationId__c = :DailyReportIdentificationId];
					// 日報OBJデータあり
					if(DailyReportList.size() > 0){
						// 日報IDを取得
						DailyReport__c DailyReportSLT = DailyReportList.get(0);
						DailyReportId = DailyReportSLT.Id;
					}
                }

                // -------------------------------------------------------------------------------------------------------------------
				// 終日行動がFalesの場合
				// 表示用の開始時間と終了時間を設定
				// -------------------------------------------------------------------------------------------------------------------
				// 開始時間を設定
				String StartDateTimeSTR = '';
				String StartTime= '';
				// 終了時間を設定
				String EndDateTimeSTR = '';
                String EndTime = '';

                if(Event.IsAllDayEvent == False){
					// ----------------------------------------------------------------------------
					// [表示用]開始時間を設定
					// ----------------------------------------------------------------------------
					if(0 <= StartDateTime.minute() && StartDateTime.minute() < 9){
						StartDateTimeSTR = '0'+ String.valueof(StartDateTime.minute());
					}else{
						StartDateTimeSTR = String.valueof(StartDateTime.minute());
					}
					StartTime = String.valueof(StartDateTime.hour()) + ':' + StartDateTimeSTR;

					// ----------------------------------------------------------------------------
					// [表示用]終了時間を設定
					// ----------------------------------------------------------------------------
                    if(0 <= EndDateTime.minute() && EndDateTime.minute() < 9){
						EndDateTimeSTR = '0'+ String.valueof(EndDateTime.minute());
					}else{
						EndDateTimeSTR = String.valueof(EndDateTime.minute());
					}
					EndTime = String.valueof(EndDateTime.hour()) + ':' + EndDateTimeSTR;
					// 日付より終了時間が大きいの場合は、頭に”翌”を付与
					if(ActivityDate.format() < EndDateTime.format()){
						EndTime = '翌' + EndTime;
					}
                }

				// 行動OBJの関連先に値が入っていない場合は、日報IDをひもつける
				if(WID == null){
					WID = DailyReportId;
				}

                // -----------------------------------------------------
				// 行動OBJに日報IDを設定して更新
				// -----------------------------------------------------    
				// 行動OBJ
				List<Event> EventTMP = new List<Event>();

				// 行動OBJの更新データを設定
				EventTMP.add(new Event(
													Id = EventID, 
													WhatId = WID,
													StartTime__c = StartTime, 
													EndTime__c = EndTime, 
													DailyReportId__c = DailyReportId
										)
				); 

				// 行動データ更新登録
 				if (EventTMP.size() > 0) {
//System.debug('行動データ　'+EventTMP);
					try{
						update EventTMP;
					}catch(DmlException e){
						System.debug('行動OBJの更新登録失敗');
						Integer errNum = e.getNumDml();
						for(Integer i = 0; i < errNum; i++){
							EventTMP.get(e.getDmlIndex(i)).addError('行動データ更新時にエラーが発生しました'+e.getDmlMessage(i));
						}
					}
				}
			}
		}

        // after delete処理
        if (Trigger.isAfter && Trigger.isDelete) {
//System.debug('after delete処理　');
        }

        // after undelete処理
        if (Trigger.isAfter && Trigger.isUnDelete ){
//System.debug('after undelete処理　');
        }

        // before insert処理
        if(Trigger.isBefore && Trigger.isInsert){
//System.debug('before insert処理　');
        }
        
        // before update処理
        if (Trigger.isBefore && Trigger.isUpdate) {
//System.debug('before update処理　');
        } 
        
        // before delete処理
        if (Trigger.isBefore && Trigger.isDelete) {
//System.debug('before delete処理　');
        }
    }
}
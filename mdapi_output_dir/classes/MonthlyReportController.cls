public without sharing class MonthlyReportController {

    // 勤怠OBJからボタンで呼び出し
	@AuraEnabled
    public static String MonthlyReportAccounting(ID MRid) {

        // 勤怠データを検索
        List<MonthlyReport__c> MonthlyReportList = [SELECT Id, DataLock__c, MasterMemberId__c, SalaryMonth__c, OwnerId
							                    	                                    					FROM MonthlyReport__c 
                        								                                					WHERE Id = :MRid];

	    // 勤怠OBJデータあり
    	if(MonthlyReportList.size() == 0){
            // データなしメッセージ
			return '勤怠データがありません！';
        }

        // 勤怠データを取得
        MonthlyReport__c MonthlyReport = MonthlyReportList.get(0);
//System.debug('MonthlyReport　'+MonthlyReport);

        // データロックがTRUEの場合、エラーメッセージ
        if(MonthlyReport.DataLock__c == TRUE){
            // データロックメッセージ
			return 'データがロックされているため算出できません！';
        }
        else{
        	// 算出項目を定義
			Decimal WorkTimeHour = 0;
			Decimal RealLabor = 0;
			Decimal PaidTimeHour = 0;
			Decimal WorkDays = 0;
			Decimal HolidayDays = 0;
			Decimal HolidayWorkDays = 0;
			Decimal HolidayWorkTime = 0;
			Decimal FixedOvertimeContract = 0;
			Decimal OverTimeHour = 0;
			Decimal MidnightTimeHour = 0;
			Decimal AcquisitionDays = 0;
			Decimal AcquisitionTime = 0;
			Decimal RemainingPaidDate = 0;
			Decimal RemainingPaidHour = 0;

            Date SalaryClosingDate = null;
            Integer SalaryClosingDay = 0;
            Date STRDT = null;
            Date ENDDT = null;

            // 所有者IDを設定
			ID OwnID = MonthlyReport.OwnerId;
            
	        // 勤怠IDを設定
			ID MonthlyReportId = MonthlyReport.Id;

            // 有給休暇ID
			ID PaidHolidaysId = null;

	        // -----------------------------------------------------------------------------------
    	    // 前回紐付け分の日報データの勤怠IDをクリア
	        // -----------------------------------------------------------------------------------
			// 日報OBJ
    		List<DailyReport__c> DailyReportTMP0 = new List<DailyReport__c>();

	        List<DailyReport__c> DailyReportList0 = [SELECT Id FROM DailyReport__c 
																						WHERE MonthlyReportId__c = :MonthlyReportId];
//System.debug('日報データ　'+DailyReportList0);
	        // 取得数分繰り返し
    		for(integer i=0; DailyReportList0.size()>i; i++){
                // データ取得
				DailyReport__c DailyReport0 = DailyReportList0.get(i);

//System.debug('DailyReport0　'+DailyReport0);
		        // 日報データに関連勤怠を設定（関連勤怠の紐付けクリア）
	    	    DailyReportTMP0.add(new DailyReport__c(
					        	        	                    Id = DailyReport0.Id, 
                												MonthlyReportId__c = NULL
					                	        	            )
	            ); 
            }
		    // 日報データの更新（関連勤怠の紐付けクリア）
    		if (DailyReportTMP0.size() > 0) {
//System.debug('日報データクリア　'+DailyReportTMP0);
				try{
            		update DailyReportTMP0;
                }catch(DmlException e){
                    System.debug('日報OBJの更新失敗');
	                Integer errNum = e.getNumDml();
	    	        for(Integer i = 0; i < errNum; i++){
    	    	    	DailyReportTMP0.get(e.getDmlIndex(i)).addError('日報データ更新時にエラーが発生しました'+e.getDmlMessage(i));
						// 処理エラーメッセージ
						return '日報データの更新時にエラーが発生しました！';
        	    	}
            	}
            }


            // メンバーマスタIDを設定
    	    ID MasterMemberId = MonthlyReport.MasterMemberId__c;
//System.debug('MasterMemberId　'+MasterMemberId);

        	// 給与月を設定
        	Date SalaryMonth = MonthlyReport.SalaryMonth__c;

	        // 給与締め日と算出期間を設定（給与月-１月の給与締日+１日〜給与月の給与締日）
	        // カスタムメタデータより給与締め日を取得
		    Kyosin7Setting__mdt Kyosin7Setting = [SELECT MasterLabel, SalaryClosingDate__c  
        		                                                                        FROM Kyosin7Setting__mdt];

            if(Kyosin7Setting.SalaryClosingDate__c == '末日'){
                // 給与月の末日を算出
				SalaryClosingDate = Date.newInstance(SalaryMonth.year(), SalaryMonth.month() + 1 ,0);
                SalaryClosingDay = SalaryClosingDate.day();
	        	STRDT = date.newInstance(SalaryMonth.year(), SalaryMonth.month(), 1);
    	    	ENDDT = date.newInstance(SalaryMonth.year(), SalaryMonth.month(), SalaryClosingDay);
            }
            else{
				// 締め日を数値化
				SalaryClosingDay = Integer.valueOf(Kyosin7Setting.SalaryClosingDate__c);
	        	STRDT = date.newInstance(SalaryMonth.year(), SalaryMonth.month()-1, SalaryClosingDay+1);
    	    	ENDDT = date.newInstance(SalaryMonth.year(), SalaryMonth.month(), SalaryClosingDay);
            }
System.debug('STRDT　'+STRDT);
System.debug('ENDDT　'+ENDDT);

	        // メンバーOBJより所定労働時間、固定残業の取得
			// メンバーOBJを取得
           	List<MasterMember__c> MasterMemberList = [SELECT Id, UserId__c, FixedOvertime__c
                    	                                    						FROM MasterMember__c 
                        	                                						WHERE Id = :MasterMemberId];
	        // メンバーOBJデータあり
    	    if(MasterMemberList.size() > 0){
                // データ取得
				MasterMember__c MasterMember = MasterMemberList.get(0);

                // IDの設定
				MasterMemberId = MasterMember.Id;

                // 固定残業契約の設定
        		FixedOvertimeContract = MasterMember.FixedOvertime__c;

                // 所有者IDの設定(メンバーOBJのユーザIDが設定されている場合)
                if(MasterMember.UserId__c != null){
					OwnID = MasterMember.UserId__c;
                }

            }

	        // 有給休暇OBJより有休残日数、有休残時間の取得
	        // 給与月より
			// 有給休暇OBJを取得
           	List<PaidHolidays__c> PaidHolidaysList = [SELECT Id, PaidLeaveRemainingDays__c, PaidLeaveRemainingTime__c
                    	                                    						FROM PaidHolidays__c 
                        	                                						WHERE MasterMemberId__c = :MasterMemberId
																					AND (NextGrantDate__c > :ENDDT OR NextGrantDate__c = Null) ];
	        // 有給休暇OBJデータあり
    	    if(PaidHolidaysList.size() > 0){
                // データ取得
				PaidHolidays__c PaidHolidays = PaidHolidaysList.get(0);

                // IDの設定
				PaidHolidaysId = PaidHolidays.Id;

                // 有休残（日）の設定（集計時の値）
                RemainingPaidDate = PaidHolidays.PaidLeaveRemainingDays__c;
        		// 有休残（時間）の設定（集計時の値）
        		RemainingPaidHour = PaidHolidays.PaidLeaveRemainingTime__c;

            }

	        // -----------------------------------------------------------
    	    // 日報データより給与データ算出
        	// -----------------------------------------------------------
			// 日報OBJ
    		List<DailyReport__c> DailyReportTMP = new List<DailyReport__c>();

            // 日報OBJデータを取得
           	List<DailyReport__c> DailyReportList = [SELECT Id, DailyReportType__c, WorkTimeHour__c, ActualTime__c,
    	                                                											PaidTimeHour__c, HolidayWorkTime__c, OverTimeHour__c,
																									MidnightTimeHour__c, AcquisitionDays__c, AcquisitionTime__c
                    	                                    						FROM DailyReport__c 
                        	                                						WHERE Date__c >= :STRDT
                                                   									AND Date__c <= :ENDDT
                                                   									AND MasterMemberId__c = :MasterMemberId
                                                    								AND MonthlyReportLock__c = False
                                                   									ORDER BY Date__c ASC];

//System.debug('DailyReportList.size　'+DailyReportList.size());
	        // 取得数分繰り返し
    		for(integer i=0; DailyReportList.size()>i; i++){

                // データ取得
				DailyReport__c DailyReport = DailyReportList.get(i);
//System.debug('DailyReport　'+DailyReport);

	        	// 総労働時間の積上げ
	        	WorkTimeHour = WorkTimeHour + DailyReport.WorkTimeHour__c;

    	    	// 実労働時間の積上げ
	        	RealLabor = RealLabor + DailyReport.ActualTime__c;

    	    	// 有休時間の積上げ
	        	PaidTimeHour = PaidTimeHour + DailyReport.PaidTimeHour__c;

        		// 出勤日数の算出
                if(DailyReport.DailyReportType__c == '出勤'){
                    WorkDays = WorkDays + 1;
                }

    	    	// 休日日数の算出
                if(DailyReport.DailyReportType__c == '休日' ||
                    DailyReport.DailyReportType__c == '代休' ||
                    DailyReport.DailyReportType__c == '特休' ){
                    HolidayDays = HolidayDays + 1;
                }

	    	    // 休日出勤日数の算出
                if(DailyReport.DailyReportType__c == '休日出勤'){
                    HolidayWorkDays = HolidayWorkDays + 1;
                }

    		    // 休日出勤時間の算出
	        	HolidayWorkTime = HolidayWorkTime + DailyReport.HolidayWorkTime__c;

        		// 時間外労働時間の積上げ
	        	OverTimeHour = OverTimeHour + DailyReport.OverTimeHour__c;

	        	// 深夜労働時間の積上げ
	        	MidnightTimeHour = MidnightTimeHour + DailyReport.MidnightTimeHour__c;

        		// 遅刻回数の積上げ(遅刻判定の積上げ）

    	    	// 出張の積上げ
//                if(DailyReport.Trip__c == TRUE){
//					BusinessTripAllowance = BusinessTripAllowance + 1;
//                }

                // 有休消化（日）の算出
                if(DailyReport.AcquisitionDays__c != null){
	                AcquisitionDays = AcquisitionDays + Decimal.valueOf(DailyReport.AcquisitionDays__c);
                }
        		// 有休消化（時間）の算出
                if(DailyReport.AcquisitionTime__c != null){
	        		AcquisitionTime = AcquisitionTime + Decimal.valueOf(DailyReport.AcquisitionTime__c);
                }

		        // 日報データに関連勤怠を設定
	    	    DailyReportTMP.add(new DailyReport__c(
					        	        	                    Id = DailyReport.Id, 
                												MonthlyReportId__c = MonthlyReportId
					                	        	            )
	            ); 
            }

		    // 日報データの更新（関連給与計算の紐付け）
    		if (DailyReportTMP.size() > 0) {
//System.debug('日報データ IN　'+DailyReportTMP);
				try{
            		update DailyReportTMP;
                }catch(DmlException e){
                    System.debug('日報OBJの更新失敗');
	                Integer errNum = e.getNumDml();
	    	        for(Integer i = 0; i < errNum; i++){
    	    	    	DailyReportTMP.get(e.getDmlIndex(i)).addError('日報データ更新時にエラーが発生しました'+e.getDmlMessage(i));
						// 処理エラーメッセージ
						return '日報データの更新時にエラーが発生しました！';
        	    	}
            	}
            }

            
            // -----------------------------------------------------------
    	    // 勤怠OBJの更新
        	// -----------------------------------------------------------
        	// 勤怠OBJ
    	    List<MonthlyReport__c> MonthlyReportTMP = new List<MonthlyReport__c>();

            // 現在時刻を取得
            Datetime CurrentTime = Datetime.now();
//System.debug('CurrentTime　'+CurrentTime);

	        // 勤怠データの設定
    	    MonthlyReportTMP.add(new MonthlyReport__c(
					        	        	                    Id = MonthlyReportId, 
                												WorkTimeHour__c = WorkTimeHour,
																RealLabor__c = RealLabor,
                												PaidTimeHour__c = PaidTimeHour,
																WorkDays__c = WorkDays,
																HolidayDays__c = HolidayDays,
																HolidayWorkDays__c = HolidayWorkDays,
																HolidayWorkTime__c = HolidayWorkTime,
//																FixedOvertimeContract__c = FixedOvertimeContract,
																OverTimeHour__c = OverTimeHour,
																MidnightTimeHour__c = MidnightTimeHour,
                												RemainingPaidDate__c = RemainingPaidDate,
                												RemainingPaidHour__c = RemainingPaidHour,
                												AcquisitionDays__c = AcquisitionDays,
                												AcquisitionTime__c = AcquisitionTime,
                												LastAffregateDate__c = CurrentTime,
																OwnerId = OwnID
                	        	            )
            ); 

    	    // データ更新
    		if (MonthlyReportTMP.size() > 0) {
//System.debug('勤怠データ IN　'+MonthlyReportTMP);
				try{
            		update MonthlyReportTMP;
                }catch(DmlException e){
                    System.debug('勤怠OBJの更新失敗');
	                Integer errNum = e.getNumDml();
	    	        for(Integer i = 0; i < errNum; i++){
    	    	    	MonthlyReportTMP.get(e.getDmlIndex(i)).addError('勤怠データ更新時にエラーが発生しました'+e.getDmlMessage(i));
						// 処理エラーメッセージ
						return '勤怠の更新時にエラーが発生しました！';
        	    	}
            	}
            }

			// 処理完了メッセージ
			return '算出処理が完了しました！';
        }
    }
}
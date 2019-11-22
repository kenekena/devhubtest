trigger TimeStampAuto on TimeStamp__c (
    after insert
//  after update,
//  after delete,
//  after undelete,
//  before insert,
//  before update,
//  before delete
){
    // -----------------------------------------------------
    // カスタムメタデータ取得
    // -----------------------------------------------------
    Kyosin7Setting__mdt Kyosin7Setting = [SELECT MasterLabel, TimeStampAuto__c, 
                                                                                        TimeStamp_TimeInputType__c, 
                                                                                        TimeStamp_BeforeWorkingHours__c,
                                                                                        TimeStamp_ScheduledTime__c
                                                                            FROM Kyosin7Setting__mdt];
//System.debug('Kyosin7Setting__mdt '+Kyosin7Setting.MasterLabel);
//System.debug('TimeStampAuto__c '+Kyosin7Setting.TimeStampAuto__c);
//System.debug('TimeStamp_TimeInputType__c '+Kyosin7Setting.TimeStamp_TimeInputType__c);

    // 打刻自動処理がTrueの場合処理する
    if(Kyosin7Setting.TimeStampAuto__c == True){

        // after insert処理
        if (Trigger.isAfter && Trigger.isInsert) {
System.debug('TimeStamp__c after insert処理 ');

            // -----------------------------------------------------
            // 打刻OBJデータ取得
            // -----------------------------------------------------
            // 打刻レコード取得
            List<TimeStamp__c> TimeStampList = Trigger.new;
            TimeStamp__c TimeStamp = TimeStampList.get(0);
System.debug('TimeStamp '+TimeStamp);

            // ------------------------------------------------------------------
            // 関連メンバーと所有者を設定
            // ------------------------------------------------------------------    
            Boolean DailyReportFLG = True;
            String MasterMemberId = null;
            String OwnId = null;
            String RegularTimeStart = null;
            String RegularTimeEnd = null;

            // ICカード打刻の場合
            if( TimeStamp.IcCard__c == True ){
                // 打刻のメンバーIDを関連メンバーに設定
                MasterMemberId = TimeStamp.MasterMemberId__c;
//System.debug('ICカード打刻 MasterMemberId '+MasterMemberId);
                // 関連メンバーからメンバーOBJの関連ユーザを所有者に設定
                MasterMember__c MasterMemberList0 = [SELECT Id,UserId__c, RegularTimeStart__c, RegularTimeEnd__c FROM MasterMember__c WHERE Id = :MasterMemberId];
                if(MasterMemberList0.UserId__c == null){
                    OwnId = TimeStamp.OwnerId;
                }else{
                    OwnId = MasterMemberList0.UserId__c;

                    // 日報へ予定時間を設定がTRUEの場合
	    	        // メンバーマスタの定時開始、定時終了を設定
    	    	    if(Kyosin7Setting.TimeStamp_ScheduledTime__c == True){
        	    	    RegularTimeStart = MasterMemberList0.RegularTimeStart__c;
            	    	RegularTimeEnd = MasterMemberList0.RegularTimeEnd__c;
            		}
                }
            }
            // 手動打刻の場合
            else{
                // 所有者を設定
                OwnId = TimeStamp.OwnerId;
                // 打刻の作成者から関連メンバーを設定
                String CRTID = TimeStamp.CreatedById;
                List<MasterMember__c> MasterMemberList = [SELECT Id, RegularTimeStart__c, RegularTimeEnd__c FROM MasterMember__c WHERE UserId__c = :CRTID];
                if(MasterMemberList.size() > 0){
                    MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
					// 関連メンバーを設定
                    MasterMemberId = MasterMemberSLT.Id;

                    // 日報へ予定時間を設定がTRUEの場合
	    	        // メンバーマスタの定時開始、定時終了を設定
    	    	    if(Kyosin7Setting.TimeStamp_ScheduledTime__c == True){
        	    	    RegularTimeStart = MasterMemberSLT.RegularTimeStart__c;
            	    	RegularTimeEnd = MasterMemberSLT.RegularTimeEnd__c;
            		}
                }
                // メンバーIDが取得できない場合は日報レコード作成なし
                else{
                    // フラグ＝False
                    DailyReportFLG = False;
                }
            }
//System.debug('DailyReportFLG '+DailyReportFLG);
//System.debug('関連メンバーID '+MasterMemberId);
//System.debug('所有者 '+OwnId);

            // ------------------------------------------------------------------
            // 日報識別IDを設定(日付＋関連メンバー)
            // ------------------------------------------------------------------    
            String DailyReportIdentificationId = String.valueOf(TimeStamp.CreatedDate).left(10) + MasterMemberId;

            // 退社打刻の場合、前日の勤務か確認
            if(TimeStamp.TimeStampType__c == '退社打刻'){
                // 作成日が打刻_前日の勤務に含める退社時間以下の場合
                // 日付を−１日にする（前日の勤務扱い）
                if(TimeStamp.CreatedDate.hour() < Kyosin7Setting.TimeStamp_BeforeWorkingHours__c ||
                   (TimeStamp.CreatedDate.hour() == Kyosin7Setting.TimeStamp_BeforeWorkingHours__c &&
                    TimeStamp.CreatedDate.minute() == 0)){
                    DailyReportIdentificationId = String.valueOf(TimeStamp.CreatedDate-1).left(10) + MasterMemberId;                
//System.debug('日報識別ID　1 '+DailyReportIdentificationId);
                }
                // 打刻_時間入力種別が入力アシストかつ出勤時間(選択)に値が入っている場合
                if((Kyosin7Setting.TimeStamp_TimeInputType__c == '入力アシスト' || TimeStamp.TimeInputType__c == '入力アシスト') &&
                    TimeStamp.LeavingTimeSelection__c != null){
                    // 退社時間が翌XXの時間の場合、日付を−１日にする（前日の勤務扱い）
                    if(TimeStamp.LeavingTimeSelection__c.left(1) == '翌')
                        DailyReportIdentificationId = String.valueOf(TimeStamp.CreatedDate-1).left(10) + MasterMemberId;
//System.debug('日報識別ID　2 '+DailyReportIdentificationId);
                }
                // 打刻_時間入力種別が手入力かつ[システム]選択時間に値が入っている場合
                if((Kyosin7Setting.TimeStamp_TimeInputType__c == '手入力' || TimeStamp.TimeInputType__c == '手入力') &&
                    TimeStamp.CalculationTimeSelection__c != null){
//System.debug('TimeStamp.CalculationTimeSelection__c '+TimeStamp.CalculationTimeSelection__c);
//System.debug('TimeStamp.CalculationTimeSelection__c.hour() '+TimeStamp.CalculationTimeSelection__c.hour());
//System.debug('TimeStamp.CalculationTimeSelection__c.minute() '+TimeStamp.CalculationTimeSelection__c.minute());
//System.debug('Kyosin7Setting.TimeStamp_BeforeWorkingHours__c '+Kyosin7Setting.TimeStamp_BeforeWorkingHours__c);
                    // [システム]選択時間が打刻_前日の勤務に含める退社時間以下の場合
                    // 日付を−１日にする（前日の勤務扱い）
                    if(TimeStamp.CalculationTimeSelection__c.hour() < Kyosin7Setting.TimeStamp_BeforeWorkingHours__c ||
                       (TimeStamp.CalculationTimeSelection__c.hour() == Kyosin7Setting.TimeStamp_BeforeWorkingHours__c &&
                        TimeStamp.CalculationTimeSelection__c.minute() == 0)){
                        DailyReportIdentificationId = String.valueOf(TimeStamp.CalculationTimeSelection__c-1).left(10) + MasterMemberId;                
//System.debug('日報識別ID　3 '+DailyReportIdentificationId);
                    }
                }
            }
//System.debug('TimeStamp__c DailyReportIdentificationId '+DailyReportIdentificationId);


            // ------------------------------------------------------------------
            // 作成日より日付を設定
            // ------------------------------------------------------------------    
            Date TSDT = Date.valueOf(String.valueOf(TimeStamp.CreatedDate).left(10));

            // ------------------------------------------------------------------
            // 出勤時間、退勤時間を設定
            // 打刻_時間入力種別により算出が変わる
            // ------------------------------------------------------------------    
            // 項目定義
            String DT1 = null;
            String DT2 = null;
            String hourStr = null;
            String minuteStr = null;
            // 作成日を時・分に分解
            Integer hour = TimeStamp.CreatedDate.hour();
            Integer minute = TimeStamp.CreatedDate.minute();

            // -------------------------------------------------------------------------------------
            // 打刻_時間入力種別が入力アシストの場合
            // -------------------------------------------------------------------------------------
            if((Kyosin7Setting.TimeStamp_TimeInputType__c == '入力アシスト' || TimeStamp.TimeInputType__c == '入力アシスト')){

                // 出社打刻の場合
                if(TimeStamp.TimeStampType__c == '出社打刻'){

                    // 出勤時間(選択)に値が入っている場合は、出勤時間(選択)から算出
                    if(TimeStamp.AttendanceTimeSelection__c != null){
                        DT1 = TimeStamp.AttendanceTimeSelection__c;
                        DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + TimeStamp.AttendanceTimeSelection__c +':00';
                    }
                    // 出勤時間がNULL場合は、作成日から算出
                    else{
                        // 時分の設定（３０分切り上げ）、分が３１分以上の場合は時に＋１を設定
                        if(minute > 30){
                            minuteStr = '00';
                            hour = hour + 1;
                            if(hour == 24)
                                hour = 0;
                        }
                        if(minute <= 30)
                            minuteStr = '30';
                        if(0 == minute)
                            minuteStr = '00';

                        hourStr = String.valueOf(hour);
                        // 出勤時間を設定
                        DT1 = hourStr + ':' + minuteStr;
                        DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + DT1 +':00';
                    }
                }

                // 退社打刻の場合
                if(TimeStamp.TimeStampType__c == '退社打刻'){

                    // 退勤時間が(選択)に値が入っている場合は、退勤時間(選択)から算出
                    if(TimeStamp.LeavingTimeSelection__c != null){
                        DT1 = TimeStamp.LeavingTimeSelection__c;
                        DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + TimeStamp.LeavingTimeSelection__c +':00';
                        // 打刻OBJの退勤時間が翌XX：XXの場合
                        if(TimeStamp.LeavingTimeSelection__c.left(1) == '翌'){
                            // 翌をカットして日時を設定
                            DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + TimeStamp.LeavingTimeSelection__c.replace('翌', '') + ':00';
                            // 日付を-1日して設定
                            TSDT = Date.valueOf(String.valueOf(TimeStamp.CreatedDate).left(10)).addDays(-1);
                        }
//System.debug('DT1　入力アシスト　'+DT1);
//System.debug('DT2　入力アシスト　'+DT2);
//System.debug('TSDT　入力アシスト　'+TSDT);
                    }
                    // 退勤時間がNULL場合は、作成日から算出
                    else{
                        // 時分の設定（３０分切り下げ）
                        if(minute >= 30){
                            minuteStr = '30';
                        }else{
                            minuteStr = '00';
                        }
                        hourStr = String.valueOf(hour);
                        // 退勤時間を設定
                        DT1 = hourStr + ':' + minuteStr;
                        DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + DT1 +':00';
//System.debug('DT1　入力アシスト2　'+DT1);
//System.debug('DT2　入力アシスト2　'+DT2);
                    }
                }
            }

            // -------------------------------------------------------------------------------------
            // 打刻_時間入力種別が30分刻みの場合、作成日から時間を算出
            // -------------------------------------------------------------------------------------
            if((Kyosin7Setting.TimeStamp_TimeInputType__c == '30分刻み' || TimeStamp.TimeInputType__c == '30分刻み')){

                // 出社打刻の場合
                if(TimeStamp.TimeStampType__c == '出社打刻'){
                    // 時分の設定（３０分切り上げ）、分が３１分以上の場合は時に＋１を設定
                    if(minute > 30){
                        minuteStr = '00';
                        hour = hour + 1;
                        if(hour == 24)
                            hour = 0;
                    }
                    if(minute <= 30)
                        minuteStr = '30';
                    if(0 == minute)
                        minuteStr = '00';

                    hourStr = String.valueOf(hour);
                    // 出勤時間を設定
                    DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) +  hourStr + ':' + minuteStr +':00';
                }

                // 退社打刻の場合
                if(TimeStamp.TimeStampType__c == '退社打刻'){
                    // 時分の設定（３０分切り下げ）
                    if(minute >= 30)
                        minuteStr = '30';
                    else
                        minuteStr = '00';

                    hourStr = String.valueOf(hour);
                    // 退勤時間を設定
                    DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + hourStr + ':' + minuteStr +':00';
                }
//System.debug('DT2　30分　'+DT2);
            }

            // -------------------------------------------------------------------------------------
            // 打刻_時間入力種別が15分刻みの場合、作成日から時間を算出
            // -------------------------------------------------------------------------------------
            if((Kyosin7Setting.TimeStamp_TimeInputType__c == '15分刻み' || TimeStamp.TimeInputType__c == '15分刻み')){

                // 出社打刻の場合
                if(TimeStamp.TimeStampType__c == '出社打刻'){
                    // 時分の設定（15分切り上げ）、分が45分以上の場合は時に＋１を設定
                    if(minute > 45){
                        minuteStr = '00';
                        hour = hour + 1;
                        if(hour == 24)
                            hour = 0;
                    }
                    if(minute <= 45)
                        minuteStr = '45';
                    if(minute <= 30)
                        minuteStr = '30';
                    if(minute <= 15)
                        minuteStr = '15';
                    if(0 == minute)
                        minuteStr = '00';

                    hourStr = String.valueOf(hour);
                    // 出勤時間を設定
                    DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + hourStr + ':' + minuteStr +':00';
                }
                
                // 退社打刻の場合
                if(TimeStamp.TimeStampType__c == '退社打刻'){
                    // 時分の設定（15分単位切り下げ）
                    if(minute >= 45)
                        minuteStr = '45';
                    else if(minute >= 30)
                        minuteStr = '30';
                    else if(minute >= 15)
                        minuteStr = '15';
                    else if(minute < 15)
                        minuteStr = '00';

                    hourStr = String.valueOf(hour);
                    // 退勤時間を設定
                    DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + hourStr + ':' + minuteStr +':00';
                }
//System.debug('DT2　15分　'+DT2);
            }

            // -------------------------------------------------------------------------------------
            // 打刻_時間入力種別がタイムスタンプの場合、作成日から時間を算出
            // -------------------------------------------------------------------------------------
            if((Kyosin7Setting.TimeStamp_TimeInputType__c == 'タイムスタンプ' || TimeStamp.TimeInputType__c == 'タイムスタンプ')){
                // 時間に作成日を設定
                hourStr = String.valueOf(hour);
                minuteStr = String.valueOf(minute);
                DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + hourStr + ':' + minuteStr +':00';

                if(TimeStamp.CreatedDate.hour() < Kyosin7Setting.TimeStamp_BeforeWorkingHours__c ||
                    (TimeStamp.CreatedDate.hour() == Kyosin7Setting.TimeStamp_BeforeWorkingHours__c &&
                    TimeStamp.CreatedDate.minute() == 0)){
                    // 日付を-1日して設定
                    TSDT = Date.valueOf(String.valueOf(TimeStamp.CreatedDate).left(10)).addDays(-1);
                }

//System.debug('DT2 タイムスタンプ '+DT2);
//System.debug('TSDT タイムスタンプ '+TSDT);
            }

            // -------------------------------------------------------------------------------------
            // 打刻_時間入力種別が手入力の場合、[システム]選択時間から時間を算出
            // -------------------------------------------------------------------------------------
            if((Kyosin7Setting.TimeStamp_TimeInputType__c == '手入力' || TimeStamp.TimeInputType__c == '手入力')){
                // [システム]選択時間に値が入っている場合
                if(TimeStamp.CalculationTimeSelection__c != null){
                    // 出勤時間に[システム]選択時間を設定
                    hour = TimeStamp.CalculationTimeSelection__c.hour();
                    minute = TimeStamp.CalculationTimeSelection__c.minute();
                    hourStr = String.valueOf(hour);
                    minuteStr = String.valueOf(minute);
                    DT2 = String.valueOf(TimeStamp.CalculationTimeSelection__c).left(11) + hourStr + ':' + minuteStr +':00';
                }
                // [システム]選択時間に値が入っていない場合、作成日を設定
                else{
                    // 出勤時間に作成日を設定
                    hourStr = String.valueOf(hour);
                    minuteStr = String.valueOf(minute);
                    DT2 = String.valueOf(TimeStamp.CreatedDate).left(11) + hourStr + ':' + minuteStr +':00';
                 }
//System.debug('DT2 手入力 '+DT2);
            }

            
            // -----------------------------------------------------
            // 日報OBJデータ作成or更新処理
            // -----------------------------------------------------    
            // 日報OBJ
            List<DailyReport__c> DailyReportListTMP = new List<DailyReport__c>();
            // 日報ID設定
            ID DRID = null;
            // 予定出勤時間を設定（メンバーマスタの定時開始を設定）
            String ScheduledAttendanceTime = RegularTimeStart;
            // 予定退勤時間を設定（メンバーマスタの定時終了を設定）
            String ScheduledLleavingTime = RegularTimeEnd;

            // -----------------------------------------------------
            // 日報OBJデータ取得
            // -----------------------------------------------------    
            // 日報識別IDより日報データを取得
            List<DailyReport__c> DailyReportList = [SELECT Id, ScheduledAttendanceTime__c, ScheduledLeavingTime__c FROM DailyReport__c WHERE DailyReportIdentificationId__c = :DailyReportIdentificationId];

            // 日報OBJデータがあれば先に日報IDを設定
            if(DailyReportList.size() > 0){
                // 日報OBJデータ取得
                DailyReport__c DailyReportSLT = DailyReportList.get(0);
                // 日報ID設定
                DRID = DailyReportSLT.Id;

                // 予定出勤時間がNull以外の場合、所得した値を設定
                if(DailyReportSLT.ScheduledAttendanceTime__c != null){
	                ScheduledAttendanceTime = DailyReportSLT.ScheduledAttendanceTime__c;
                }
                // 予定退勤時間がNull以外の場合、所得した値を設定
                if(DailyReportSLT.ScheduledLeavingTime__c != null){
	                ScheduledLleavingTime = DailyReportSLT.ScheduledLeavingTime__c;
                }
            }

//System.debug('TimeStamp__c DailyReportList.size　'+DailyReportList.size());
            // -----------------------------------------------------
            // 日報OBJデータなし　 日報OBJデータ作成
            // -----------------------------------------------------
            if(DailyReportList.size() == 0){
                // 打刻OBJの種別により処理判定
                // 打刻OBJの種別が出社打刻かつ日報フラグがTrueかつ
                // 打刻OBJの種別が退社打刻かつ日報フラグがTrueの場合
                if(TimeStamp.TimeStampType__c != '出社打刻' && DailyReportFLG == True &&
                    TimeStamp.TimeStampType__c != '退社打刻' && DailyReportFLG == True){

                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Date__c = TSDT,
                                                                    MasterMemberId__c = MasterMemberId,
                                                                    DailyReportType__c = '出勤',
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }
                // 打刻OBJの種別が出社打刻かつ日報フラグがTrueの場合
                if(TimeStamp.TimeStampType__c == '出社打刻' && DailyReportFLG == True){

                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Date__c = TSDT,
                                                                    MasterMemberId__c = MasterMemberId,
                                                                    DailyReportType__c = '出勤',
                                                                    AttendanceComment__c = TimeStamp.Comment__c,
                                                                    AttendanceTimeSelection__c = DT1,
                                                                    TimeStampAttendanceTime__c = TimeStamp.CreatedDate,
                                                                    AttendanceTime__c = Datetime.valueOf(DT2),
                                                                    ScheduledAttendanceTime__c = ScheduledAttendanceTime,
                                                                    ScheduledLeavingTime__c = ScheduledLleavingTime,
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }
                // 打刻OBJの種別が退社打刻かつ日報フラグがTrueの場合
                if(TimeStamp.TimeStampType__c == '退社打刻' && DailyReportFLG == True){

                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Date__c = TSDT,
                                                                    MasterMemberId__c = MasterMemberId,
                                                                    DailyReportType__c = '出勤',
                                                                    LeavingComment__c = TimeStamp.Comment__c,
                                                                    LeavingTimeSelection__c = DT1,
                                                                    TimeStampLeavingTime__c = TimeStamp.CreatedDate,
                                                                    LeavingTime__c = Datetime.valueOf(DT2),
                                                                    ScheduledAttendanceTime__c = ScheduledAttendanceTime,
                                                                    ScheduledLeavingTime__c = ScheduledLleavingTime,
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }

System.debug('TimeStamp__c DailyReportListTMP'+DailyReportListTMP);

                // 日報データ新規登録
                if (DailyReportListTMP.size() > 0){
                    try{
                        insert DailyReportListTMP;
                        // 日報識別IDより日報データを取得
                        List<DailyReport__c> DailyReportList2 = [SELECT Id FROM DailyReport__c WHERE DailyReportIdentificationId__c = :DailyReportIdentificationId];
                        DailyReport__c DailyReportSLT = DailyReportList2.get(0);
                        // 日報ID設定
                        DRID = DailyReportSLT.Id;
                    }catch(DmlException e){
                        System.debug('日報OBJの新規登録失敗');
                        Integer errNum = e.getNumDml();
                        for(Integer i = 0; i < errNum; i++){
                            DailyReportListTMP.get(e.getDmlIndex(i)).addError('日報データ作成時にエラーが発生しました'+e.getDmlMessage(i));
                        }
                    }
                }
            }

            // --------------------------------------------------------------------------------------------
            // 打刻データ更新処理（関連メンバー、関連日報、[システム]選択時間）
            // 日報OBJレコードがない場合は、日報レコードを作成したから打刻レコード更新
            // 日報OBJレコードがある場合は、日報レコードの更新前に打刻レコード更新
            // --------------------------------------------------------------------------------------------
            // 打刻（更新）
            List<TimeStamp__c> TimeStampListTMP = new List<TimeStamp__c>();
            // 打刻の社員メンバーを更新
            String TimeStampId = TimeStamp.Id;
            Datetime CTS = Datetime.now();

            // 出社打刻か退社打刻の場合
            if(TimeStamp.TimeStampType__c == '出社打刻' || 
                TimeStamp.TimeStampType__c == '退社打刻'){

                // [システム]選択時間を設定
                CTS = Datetime.valueOf(DT2);

                if(TimeStamp.TimeStampType__c == '出社打刻'){ 
                    // 打刻データを設定
                    TimeStamp__c TimeStampSTR = new TimeStamp__c(
                                                                                Id = TimeStampId,
//                                                                              Date__c = Date.valueOf(String.valueOf(TimeStamp.LastModifiedDate).left(10)),
                                                                                MasterMemberId__c = MasterMemberId,
                                                                                DailyReportId__c = DRID,
                                                                                AttendanceTimeSelection__c = DT1,
                                                                                CalculationTimeSelection__c = CTS
                    );
                    TimeStampListTMP.add(TimeStampSTR);
                }
                if(TimeStamp.TimeStampType__c == '退社打刻'){ 
                    // 打刻データを設定
                    TimeStamp__c TimeStampSTR = new TimeStamp__c(
                                                                                Id = TimeStampId,
//                                                                              Date__c = Date.valueOf(String.valueOf(TimeStamp.LastModifiedDate).left(10)),
                                                                                MasterMemberId__c = MasterMemberId,
                                                                                DailyReportId__c = DRID,
                                                                                LeavingTimeSelection__c = DT1,
                                                                                CalculationTimeSelection__c = CTS
                    );
                    TimeStampListTMP.add(TimeStampSTR);
                }
                if(TimeStamp.TimeStampType__c == '外出' || 
                    TimeStamp.TimeStampType__c == '戻り'){
                    // 打刻データを設定
                    TimeStamp__c TimeStampSTR = new TimeStamp__c(
                                                                                Id = TimeStampId,
//                                                                              Date__c = Date.valueOf(String.valueOf(TimeStamp.LastModifiedDate).left(10)),
                                                                                MasterMemberId__c = MasterMemberId,
                                                                                DailyReportId__c = DRID,
                                                                                CalculationTimeSelection__c = CTS
                    );
                    TimeStampListTMP.add(TimeStampSTR);
                }
            }
            // 出社打刻か退社打刻以外
            else{
                TimeStamp__c TimeStampSTR = new TimeStamp__c(
                                                                                Id = TimeStampId,
//                                                                              Date__c = Date.valueOf(String.valueOf(TimeStamp.LastModifiedDate).left(10)),
                                                                                MasterMemberId__c = MasterMemberId,
                                                                                DailyReportId__c = DRID,
                                                                                CalculationTimeSelection__c = CTS
                );
                TimeStampListTMP.add(TimeStampSTR);
            }
System.debug('TimeStamp__c TimeStampListTMP'+TimeStampListTMP);
            //打刻を更新
            try{
                update TimeStampListTMP;
            }catch(DmlException e){
                System.debug('打刻OBJの更新失敗');
                Integer errNum = e.getNumDml();
                for(Integer i = 0; i < errNum; i++){
                    TimeStampListTMP.get(e.getDmlIndex(i)).addError('打刻データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                }
            }

//System.debug('TimeStampListTMP　'+TimeStampListTMP);

            // -------------------------------------------------------------------------
            // 日報OBJデータありの場合、日報OBJデータ更新
            // 出社打刻、退勤打刻以外の算出のために
            // 打刻OBJの関連日報を設定した後に更新
            // -------------------------------------------------------------------------
            if(DailyReportList.size() > 0){
                // 日報OBJデータ取得
                DailyReport__c DailyReportSLT = DailyReportList.get(0);
                // 日報ID設定
                DRID = DailyReportSLT.Id;

//System.debug('TimeStamp__c TimeStampType__c '+TimeStamp.TimeStampType__c);
                // 打刻OBJの種別が外出かつ日報フラグがTrueの場合
                // 打刻OBJの種別が休憩開始かつ日報フラグがTrueの場合
                // 打刻OBJの種別が移動開始かつ日報フラグがTrueの場合
                // 打刻OBJの種別が作業開始かつ日報フラグがTrueの場合
                if(TimeStamp.TimeStampType__c == '外出' && DailyReportFLG == True ||
                    TimeStamp.TimeStampType__c == '休憩開始' && DailyReportFLG == True ||
                    TimeStamp.TimeStampType__c == '移動開始' && DailyReportFLG == True ||
                    TimeStamp.TimeStampType__c == '作業開始' && DailyReportFLG == True){

                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Id=DailyReportSLT.Id,
                                                                    Date__c = TSDT,
                                                                    MasterMemberId__c = MasterMemberId,
                                                                    DailyReportType__c = '出勤',
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }
                // 打刻OBJの種別が戻りかつ日報フラグがTrueの場合（外出時間も算出のため）
                // 打刻OBJの種別が休憩終了かつ日報フラグがTrueの場合（外出時間も算出のため）
                // 打刻OBJの種別が移動終了かつ日報フラグがTrueの場合（外出時間も算出のため）
                // 打刻OBJの種別が作業終了かつ日報フラグがTrueの場合（外出時間も算出のため）
                if(TimeStamp.TimeStampType__c == '戻り' && DailyReportFLG == True ||
                    TimeStamp.TimeStampType__c == '休憩終了' && DailyReportFLG == True ||
                    TimeStamp.TimeStampType__c == '移動終了' && DailyReportFLG == True ||
                    TimeStamp.TimeStampType__c == '作業終了' && DailyReportFLG == True){
                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Id = DailyReportSLT.Id,
                                                                    MasterMemberId__c = MasterMemberId,
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }


                // 打刻OBJの種別が出社打刻かつ日報フラグがTrueの場合
                if(TimeStamp.TimeStampType__c == '出社打刻' && DailyReportFLG == True){

                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Id=DailyReportSLT.Id,
                                                                    Date__c = TSDT,
                                                                    MasterMemberId__c = MasterMemberId,
                                                                    DailyReportType__c = '出勤',
                                                                    AttendanceComment__c = TimeStamp.Comment__c,
                                                                    AttendanceTimeSelection__c = DT1,
                                                                    TimeStampAttendanceTime__c = TimeStamp.CreatedDate,
                                                                    AttendanceTime__c = Datetime.valueOf(DT2),
                                                                    ScheduledAttendanceTime__c = ScheduledAttendanceTime,
                                                                    ScheduledLeavingTime__c = ScheduledLleavingTime,
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }
                // 打刻OBJの種別が退社打刻かつ日報フラグがTrueの場合
                if(TimeStamp.TimeStampType__c == '退社打刻' && DailyReportFLG == True){

                    // 日報データを設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                    Id=DailyReportSLT.Id,
                                                                    LeavingComment__c = TimeStamp.Comment__c,
                                                                    LeavingTimeSelection__c = DT1,
                                                                    TimeStampLeavingTime__c = TimeStamp.CreatedDate,
                                                                    LeavingTime__c = Datetime.valueOf(DT2),
                                                                    ScheduledAttendanceTime__c = ScheduledAttendanceTime,
																	ScheduledLeavingTime__c = ScheduledLleavingTime,
                                                                    OwnerId = OwnId
                                                                    )
                    );
                }

System.debug('TimeStamp__c DailyReportListTMP'+DailyReportListTMP);
                // 日報OBJデータ更新
                if(DailyReportListTMP.size() > 0){
                    try{
                        update DailyReportListTMP;
                    }catch(DmlException e){
                        System.debug('日報OBJの更新失敗');
                        Integer errNum = e.getNumDml();
                        for(Integer i = 0; i < errNum; i++){
                            DailyReportListTMP.get(e.getDmlIndex(i)).addError('日報データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                        }
                    }
                }
            }



            // -----------------------------------------------------
            // メンバーOBJデータ更新処理
            // -----------------------------------------------------
            // メンバーOBJ
            List<MasterMember__c> MasterMemberListTMP = new List<MasterMember__c>();
            // 打刻OBJの種別が出社打刻の場合、メンバーOBJの「[システム]出勤状況」Trueを設定
            if(TimeStamp.TimeStampType__c == '出社打刻'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, ArrivalStatus__c = True
                                                        )
                );
            }
            // 打刻OBJの種別が移動開始の場合、メンバーOBJの作業状況　に”移動開始”を設定
            if(TimeStamp.TimeStampType__c == '移動開始'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = '移動中'
                                                        )
                );
            }
            // 打刻OBJの種別が移動終了の場合、メンバーOBJの作業状況　にNULLを設定
            if(TimeStamp.TimeStampType__c == '移動終了'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = ''
                                                        )
                );
            }
            // 打刻OBJの種別が作業開始の場合、メンバーOBJの作業状況　に”作業中”を設定
            if(TimeStamp.TimeStampType__c == '作業開始'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = '作業中'
                                                        )
                );
            }
            // 打刻OBJの種別が作業終了の場合、メンバーOBJの作業状況　にNULLを設定
            if(TimeStamp.TimeStampType__c == '作業終了'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = ''
                                                        )
                );
            }
            // 打刻OBJの種別が休憩開始の場合、メンバーOBJの作業状況　に”休暇中”を設定
            if(TimeStamp.TimeStampType__c == '休憩開始'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = '休憩中'
                                                        )
                );
            }
            // 打刻OBJの種別が休憩終了の場合、メンバーOBJの作業状況　にNULLを設定
            if(TimeStamp.TimeStampType__c == '休憩終了'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = ''
                                                        )
                );
            }
            // 打刻OBJの種別が外出の場合、メンバーOBJの作業状況　に”外出中”を設定
            if(TimeStamp.TimeStampType__c == '外出'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = '外出中'
                                                        )
                );
            }
            // 打刻OBJの種別が戻りの場合、メンバーOBJの作業状況　にNULLを設定
            if(TimeStamp.TimeStampType__c == '戻り'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, WorkingStatus__c = ''
                                                        )
                );
            }
            // 打刻OBJの種別が退社打刻の場合、メンバーOBJの「[システム]出勤状況」にFalse、作業状況にNULLを設定
            if(TimeStamp.TimeStampType__c == '退社打刻'){
                MasterMemberListTMP.add(new MasterMember__c(
                                                        Id = MasterMemberId, ArrivalStatus__c = False, WorkingStatus__c = ''
                                                        )
                );
            }
            // メンバーOBJを更新
            try{
                update MasterMemberListTMP;
            }catch(DmlException e){
                System.debug('メンバーOBJの更新失敗');
                Integer errNum = e.getNumDml();
                for(Integer i = 0; i < errNum; i++){
                    MasterMemberListTMP.get(e.getDmlIndex(i)).addError('メンバーデータ更新時にエラーが発生しました'+e.getDmlMessage(i));
                }
            }
//System.debug('MasterMemberListTMP　'+MasterMemberListTMP);

        }

        // after update処理
        if(Trigger.isAfter && Trigger.isUpdate){
//System.debug('TimeStamp__c after update処理　');
        }

        // after delete処理
        if(Trigger.isAfter && Trigger.isDelete){
//System.debug('TimeStamp__c after delete処理　');
        }

        // after undelete処理
        if(Trigger.isAfter && Trigger.isUnDelete){
//System.debug('TimeStamp__c after undelete処理　');
        }

        // before insert処理
        if(Trigger.isBefore && Trigger.isInsert){
//System.debug('TimeStamp__c before insert処理　');
        }

        // before update処理
        if(Trigger.isBefore && Trigger.isUpdate){
//System.debug('TimeStamp__c before update処理　');
        }

        // before delete処理
        if(Trigger.isBefore && Trigger.isDelete){
//System.debug('TimeStamp__c before delete処理　');
        }
    }
}
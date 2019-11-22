trigger DailyReportAuto on DailyReport__c (
    after insert,
    after update,
//  after delete,
//  after undelete,
    before insert,
    before update,
    before delete
){
    // -----------------------------------------------------
    // カスタムメタデータ取得
    // -----------------------------------------------------
    Kyosin7Setting__mdt Kyosin7Setting = [SELECT MasterLabel, DailyReportAuto__c, DailyReport_WorkingHours__c, 
                                                                                        DailyReport_MidnightStartTime__c, DailyReport_MidnightEndTime__c,
                                                                                         TimeStamp_TimeInputType__c, TimeStamp_BeforeWorkingHours__c
                                                                            FROM Kyosin7Setting__mdt];
//System.debug('DailyReportAuto__c '+Kyosin7Setting.DailyReportAuto__c);
//System.debug('DailyReport_WorkingHours__c '+Kyosin7Setting.DailyReport_WorkingHours__c);
//System.debug('TimeStamp_TimeInputType__c '+Kyosin7Setting.TimeStamp_TimeInputType__c);
//System.debug('TimeStamp_BeforeWorkingHours__c '+Kyosin7Setting.TimeStamp_BeforeWorkingHours__c);

    // 日報自動処理がTrueの場合処理する
    if(Kyosin7Setting.DailyReportAuto__c == True){
        // after insert処理
        if (Trigger.isAfter && Trigger.isInsert) {
System.debug('DailyReport__c after insert処理 ');

            //  ----------------------------------------------------------------------
            // 日報レコード作成後に処理
            // ----------------------------------------------------------------------
            // 関連メンバーの定義
            ID MemberIdOrg = null;
            // 日報レコード取得
            // 取得数分繰り返し(一括処理を考慮)
            for(DailyReport__c DailyReport : Trigger.new){
//System.debug('after insert　DailyReport '+DailyReport);

                // ------------------------------------------------------------------------------------------
                // 日報の所有者を更新
                // 関連メンバーからメンバーOBJの関連ユーザを設定
                // 関連メンバーに値なし、メンバーレコードなし、関連ユーザに値が入ってない
                // 場合は日報の所有者を設定
                // ------------------------------------------------------------------------------------------
                ID OwnID = DailyReport.OwnerId;
                // 関連メンバーに値が入っている場合
                ID MasterMemberId = DailyReport.MasterMemberId__c;
                String LaborSystem = '';
                if(MasterMemberId != null){
                    List<MasterMember__c> MasterMemberList = [SELECT Id, UserId__c FROM MasterMember__c WHERE Id = :MasterMemberId];
                    // メンバーレコードがある場合
                    if(MasterMemberList.size() > 0){
                        MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                        // メンバーIDを設定
                        MasterMemberId = MasterMemberSLT.Id;
                        // 関連ユーザに値が入っている場合
                        if(MasterMemberSLT.UserId__c != null){
                            OwnID = MasterMemberSLT.UserId__c;
                        }
                    }
                }
                // 関連メンバーに値が入っていない場合
                else{
                    List<MasterMember__c> MasterMemberList = [SELECT Id, UserId__c FROM MasterMember__c WHERE UserId__c = :OwnID];
                    // メンバーレコードがある場合
                    if(MasterMemberList.size() > 0){
                        MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                        // メンバーIDを設定
                        MasterMemberId = MasterMemberSLT.Id;
                    }
                }
//System.debug('OwnID　after '+OwnID);

                // ---------------------------------------------------------------------------------------------------------------------------
                // 日報OBJの日報種別が”休日”,”代休”,”有休”,”欠勤”,”特休”のいずれかの場合
                // 休憩時間、出勤時間、退勤時間をクリアする
                // ---------------------------------------------------------------------------------------------------------------------------
                String BreakTimeSelection = DailyReport.BreakTimeSelection__c;
                String AttendanceTimeSelection = DailyReport.AttendanceTimeSelection__c;
                String LeavingTimeSelection = DailyReport.LeavingTimeSelection__c;
                Datetime AttendanceTime = DailyReport.AttendanceTime__c;
                Datetime LeavingTime = DailyReport.LeavingTime__c;
                if(DailyReport.DailyReportType__c == '休日' || 
                    DailyReport.DailyReportType__c == '代休' || 
                    DailyReport.DailyReportType__c == '有休' || 
                    DailyReport.DailyReportType__c == '欠勤' || 
                    DailyReport.DailyReportType__c == '特休'){
                    // 休憩時間クリア
                    BreakTimeSelection = '';
                    // 出勤時間クリア
                    AttendanceTimeSelection = '';
                    AttendanceTime = null;
                    // 退勤時間クリア
                    LeavingTimeSelection = '';
                    LeavingTime = null;
                }

//System.debug('after insert DailyReport.AcquisitionDays__c '+DailyReport.AcquisitionDays__c);
                // ---------------------------------------------------------------------------------------------------------------------------
                //　日報OBJの有休取得日数もしくは有休取得時間に値が入っているまたは日報種別が有休の場合
                //　有休時間を算出(有休申請ありと判断)
                //　日報種別が有休の場合は、日報取得日数は1.0
                // ---------------------------------------------------------------------------------------------------------------------------
                Decimal PaidTime = 0;
                String AcquisitionDays = null;
                if(DailyReport.AcquisitionDays__c != null || 
                    DailyReport.AcquisitionTime__c != null ||
                    DailyReport.DailyReportType__c == '有休'){
                    // 有休申請状況を設定

                    // 有休時間を算出
                    if(DailyReport.AcquisitionDays__c != null){
                        PaidTime = PaidTime + Kyosin7Setting.DailyReport_WorkingHours__c * Decimal.valueof(DailyReport.AcquisitionDays__c)*60;
                        AcquisitionDays = DailyReport.AcquisitionDays__c;
                    }
                    if(DailyReport.AcquisitionTime__c != null){
                        PaidTime = PaidTime + Decimal.valueof(DailyReport.AcquisitionTime__c)*60;
                    }
                    if(DailyReport.AcquisitionDays__c == null && DailyReport.DailyReportType__c == '有休'){
                        PaidTime = PaidTime + Kyosin7Setting.DailyReport_WorkingHours__c * 60;
                        AcquisitionDays = '1.0';
                    }
//System.debug('DailyReport__c after insert PaidTime '+PaidTime);
                        
                    // -----------------------------------------------------
                    // 有給休暇データ更新処理
                    // -----------------------------------------------------    

                    // 差分計算
                    Decimal DifferenceDays = 0;
                    if(DailyReport.AcquisitionDays__c != null)
                        DifferenceDays = Decimal.valueof(DailyReport.AcquisitionDays__c);
                    else
                        if(AcquisitionDays != null)
	                        DifferenceDays = Decimal.valueof(AcquisitionDays);
                    Decimal DifferenceTime = 0;
                    if(DailyReport.AcquisitionTime__c != null)
                        DifferenceTime = Decimal.valueof(DailyReport.AcquisitionTime__c);

//System.debug('DailyReport__c after insert DifferenceDays '+DifferenceDays);
//System.debug('DailyReport__c after insert DifferenceTime '+DifferenceTime);

                    // 有給休暇OBJデータを取得(データロックされていないかつ年（期）の昇順)
                    List<PaidHolidays__c> PaidHolidaysList = [SELECT Id
                                                                                                FROM PaidHolidays__c
                                                                                                WHERE MasterMemberId__c = : MasterMemberId
                                                                                                AND DataLock__c = FALSE
                                                                                                ORDER BY Period__c ASC];
					// データが取得できた場合
	                if(PaidHolidaysList.size() > 0){

	                    // レコード取得
    	                PaidHolidays__c  PaidHolidays = PaidHolidaysList.get(0);
//System.debug('PaidHolidays 　'+PaidHolidays);
        	            // 有給休暇IDを設定
            	        ID PaidHolidaysId = PaidHolidays.Id;

	                    // 有給休暇OBJ
    	                List<PaidHolidays__c> PaidHolidayslistTMP = new List<PaidHolidays__c>();

	                    // 更新データ設定
    	                PaidHolidayslistTMP.add(new PaidHolidays__c(
        	                                                            Id = PaidHolidaysId,
            	                                                        DifferenceDays__c = DifferenceDays,
                	                                                    DifferenceTime__c = DifferenceTime,
                    	                                                TriggerUpdate__c = True,
                        	                                            PaidRequest__c = '申請'
                            	                                        )
                    	);
	                    // 有給休暇OBJデータ更新
    	                if(PaidHolidayslistTMP.size() > 0) {
        	                try{
//System.debug('DailyReport__c after insert PaidHolidayslistTMP '+PaidHolidayslistTMP);
            	                update PaidHolidayslistTMP;
                	        }catch(DmlException e){
                    	        System.debug('after update old 有給休暇OBJの更新失敗');
                        	    Integer errNum = e.getNumDml();
                            	for(Integer i = 0; i < errNum; i++){
                                	PaidHolidayslistTMP.get(e.getDmlIndex(i)).addError('有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                            	}
                        	}
                    	}
                    }
                    else{
                        // エラーメッセージ表示
                        for(DailyReport__c opp: Trigger.new){
                            opp.addError('有給休暇OBJが存在していないため有休の残計算ができません！');
                        }                            
                    }
                }

                // -------------------------------------------------------------------------------------------------------------
                // 日報データ更新処理(関連メンバー、勤務体系、有休申請状況、有休時間、休憩時間)
                // -------------------------------------------------------------------------------------------------------------
                // 日報OBJ
                List<DailyReport__c> DailyReportListTMP = new List<DailyReport__c>();
                // 更新データ設定
                DailyReportListTMP.add(new DailyReport__c(
                                                                Id = DailyReport.Id,
                                                                MasterMemberId__c = MasterMemberId,
                                                                PaidTime__c = PaidTime,
                                                                BreakTimeSelection__c = BreakTimeSelection,
                                                                AttendanceTime__c = AttendanceTime,
                                                                LeavingTime__c = LeavingTime,
                                                                AcquisitionDays__c = AcquisitionDays,
                                                                OwnerId = OwnID
                                                                )
                );
                // 日報OBJデータ更新
                if(DailyReportListTMP.size() > 0){
                    try{
//System.debug('DailyReport__c after insert DailyReportListTMP '+DailyReportListTMP);
                        update DailyReportListTMP;
                    }catch(DmlException e){
                        System.debug('DailyReport__c after insert 日報OBJの更新失敗');
                        Integer errNum = e.getNumDml();
                        for(Integer i = 0; i < errNum; i++){
                            DailyReportListTMP.get(e.getDmlIndex(i)).addError('日報データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                        }
                    }
                }
//System.debug('after insert 日報OBJデータ更新　');

            }
        }

        // after update処理
        if(Trigger.isAfter && Trigger.isUpdate){
System.debug('DailyReport__c after update処理　');

            // ----------------------------------------------------------------------
            // 日報レコード更新後に各種時間を算出
            // ----------------------------------------------------------------------
            // 日報レコード取得
            // 取得数分繰り返し(一括処理を考慮)
            Integer count = 0;
            for(DailyReport__c DailyReport : Trigger.new){
//System.debug('after update　DailyReport '+DailyReport);

                // IDを設定
                ID DailyReportId = DailyReport.Id;
                // 関連メンバーを設定
                ID MasterMemberListId = DailyReport.MasterMemberId__c;

                // 変更前の日報OBJの労働時間、有休取得日数、有休取得時間、出勤時間、退勤時間を取得
                List<DailyReport__c> DailyReportList_OLD = Trigger.old;
                DailyReport__c DailyReport_OLD = DailyReportList_OLD.get(count);
                count = count + 1;
                // 関連メンバーを設定
                ID MasterMemberListIdOLD = DailyReport_OLD.MasterMemberId__c;

//System.debug('after update count  '+count );
//System.debug('DailyReport__c after update DailyReport.LastModifiedDate  '+DailyReport.LastModifiedDate );
//System.debug('DailyReport__c after update DailyReport_OLD.LastModifiedDate  '+DailyReport_OLD.LastModifiedDate );
//System.debug('DailyReport__c after update DailyReport.PaidTime__c  '+DailyReport.PaidTime__c );
//System.debug('DailyReport__c after update DailyReport_OLD.PaidTime__c  '+DailyReport_OLD.PaidTime__c );
//System.debug('DailyReport__c after update DailyReport.AcquisitionDays__c  '+DailyReport.AcquisitionDays__c );
//System.debug('DailyReport__c after update DailyReport_OLD.AcquisitionDays__c  '+DailyReport_OLD.AcquisitionDays__c );
//System.debug('DailyReport__c after update DailyReport.MonthlyReportId__c  '+DailyReport.MonthlyReportId__c );
//System.debug('DailyReport__c after update DailyReport_OLD.MonthlyReportId__c  '+DailyReport_OLD.MonthlyReportId__c );
                // --------------------------------------------------------------------------------------------------------------
                // 変更前の最終更新日が前回と違うかつ有休時間が前回と違うもしくは
                // 変更前の有休取得日数が前回と違う（日報種別が有休で有休取得日数をクリアした時の場合）
                // かつ給与計算表IDが前回と同じ場合に処理する（ループ防止）
                // --------------------------------------------------------------------------------------------------------------
                if((DailyReport.LastModifiedDate != DailyReport_OLD.LastModifiedDate || 
                    DailyReport.PaidTime__c != DailyReport_OLD.PaidTime__c ||
                    DailyReport.AcquisitionDays__c != DailyReport_OLD.AcquisitionDays__c) && 
                    DailyReport.MonthlyReportId__c == DailyReport_OLD.MonthlyReportId__c){

                    // 変更前の日報OBJの労働時間を取得
                    Decimal WorkTimeOld = DailyReport_OLD.WorkTime__c;
                    // 変更前の日報OBJの有休取得日数、有休取得時間を取得
                    // 変更前の日報OBJの有休取得日数に値が入っている場合
                    Decimal AcquisitionDaysOld = 0;
                    if(DailyReport_OLD.AcquisitionDays__c != null)
                        AcquisitionDaysOld = Decimal.valueof(DailyReport_OLD.AcquisitionDays__c);

                    // 変更前の日報OBJの有休取得時間に値が入っている場合
                    Decimal AcquisitionTimeOld = 0;
                    if(DailyReport_OLD.AcquisitionTime__c != null)
                        AcquisitionTimeOld = Decimal.valueof(DailyReport_OLD.AcquisitionTime__c);

                    // 変更前の日報OBJの出勤時間、退勤時間を取得
                    String AttendanceTimeSelectionOld = DailyReport_OLD.AttendanceTimeSelection__c;
                    String LeavingTimeSelectionOld = DailyReport_OLD.LeavingTimeSelection__c;
                    Datetime AttendanceTimeOld = DailyReport_OLD.AttendanceTime__c;
                    Datetime LeavingTimeOld = DailyReport_OLD.LeavingTime__c;

//System.debug('after update AttendanceTimeOld '+AttendanceTimeOld);
//System.debug('after update LeavingTimeOld '+LeavingTimeOld);
//System.debug('DailyReport__c after update DailyReport.AttendanceTime__c '+DailyReport.AttendanceTime__c);
//System.debug('after update DailyReport.LeavingTime__c '+DailyReport.LeavingTime__c);
//System.debug('after update DailyReport.DailyReportType__c '+DailyReport.DailyReportType__c);

                    //外出、休憩、移動、作業の算出項目　の定義
                    Decimal TSGoOutTime = 0;
                    Decimal TSBreakTime = 0;
                    Decimal TSMoveTime = 0;
                    Decimal TSWorkTime = 0;
                    Decimal RTM = 0;
                    Decimal GTM = 0;

                    // ------------------------------------------------------------------------------------------
                    // 日報の所有者を更新
                    // 関連メンバーからメンバーOBJの関連ユーザを設定
                    // 関連メンバーに値なし、メンバーレコードなし、関連ユーザに値が入ってない場合は
                    // 日報の所有者者を設定
                    // ------------------------------------------------------------------------------------------
                    ID OwnID = DailyReport.OwnerId;
                    // 関連メンバーに値が入っている場合
                    ID MasterMemberId = DailyReport.MasterMemberId__c;
                    String LaborSystem = null;
                    if(MasterMemberId != null){
                        List<MasterMember__c> MasterMemberList = [SELECT Id, UserId__c FROM MasterMember__c WHERE Id = :MasterMemberId];
                        // メンバーレコードがある場合
                        if(MasterMemberList.size() > 0){
                            MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                            // メンバーIDを設定
                            MasterMemberId = MasterMemberSLT.Id;
                            // 関連ユーザに値が入っている場合
                            if(MasterMemberSLT.UserId__c != null){
                                OwnID = MasterMemberSLT.UserId__c;
                            }
                        }
                    }
                    // 関連メンバーに値が入っていない場合
                    else{
                        List<MasterMember__c> MasterMemberList = [SELECT Id, UserId__c FROM MasterMember__c WHERE UserId__c = :OwnID];
                        // メンバーレコードがある場合
                        if(MasterMemberList.size() > 0){
                            MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                            // メンバーIDを設定
                            MasterMemberId = MasterMemberSLT.Id;
                        }
                    }

                    // 算出項目の初期化
                    Decimal WorkTime = 0;
                    Decimal StartTotalTime = 0;
                    Decimal EndTotalTime = 0;
                    Decimal PaidTime = 0;
                    Decimal BreakTime = 0;
                    Decimal NakanukeTime = 0;
                    Decimal OverTime = 0;
                    Decimal MidnightTime = 0;
                    String AcquisitionDays = null;

                    //　----------------------------------------------------------------------------------
                    //　休憩時間（分）を算出（休憩時間を数値変換☓60分）
                    //　----------------------------------------------------------------------------------
                    String BreakTimeSTR = '0';
                    //　設定されている休憩時間が0より大きい場合は設定されている休憩時間
                    if(DailyReport.BreakTimeSelection__c != null){
                        if(Decimal.valueOf(DailyReport.BreakTimeSelection__c) > 0){
                            BreakTime = Decimal.valueOf(DailyReport.BreakTimeSelection__c)*60;
                            BreakTimeSTR = DailyReport.BreakTimeSelection__c;
                        }
                    }
System.debug('DailyReport__c after　update　BreakTime　'+BreakTime);
//System.debug('DailyReport__c after　update　BreakTimeSTR　'+BreakTimeSTR);

                    // ----------------------------------------------------------------------------------
                    // 有休時間を算出
                    //  前回の日報種別が有休かつ今回の日報種別が有休以外の場合は、
                    //  今回の有休取得日数が0.5以外の場合は、有休日数をクリアする
                    // ----------------------------------------------------------------------------------
                    if(DailyReport_OLD.DailyReportType__c == '有休' && DailyReport.DailyReportType__c != '有休'){
//System.debug('22222after update　DailyReport.AcquisitionDays__c '+DailyReport.AcquisitionDays__c);
                        if(DailyReport.AcquisitionDays__c != '0.5'){
                            AcquisitionDays = null;
                        }else{
//System.debug('after update　DailyReport.AcquisitionDays__c '+DailyReport.AcquisitionDays__c);
                            if(DailyReport.AcquisitionDays__c != null){
                                PaidTime = PaidTime + Kyosin7Setting.DailyReport_WorkingHours__c * Decimal.valueof(DailyReport.AcquisitionDays__c)*60;
                                AcquisitionDays = DailyReport.AcquisitionDays__c;
//System.debug('after update PaidTime1 '+PaidTime);
                            }
                            if(DailyReport.AcquisitionTime__c != null){
                                PaidTime = PaidTime + Decimal.valueof(DailyReport.AcquisitionTime__c)*60;
//System.debug('after update PaidTime2 '+PaidTime);
                            }
                            if(DailyReport.AcquisitionDays__c == null && DailyReport.DailyReportType__c == '有休'){
                                PaidTime = PaidTime + Kyosin7Setting.DailyReport_WorkingHours__c * 60;
                                AcquisitionDays = '1.0';
//System.debug('after update PaidTime3 '+PaidTime);
                            }
                        }
                    }
                    else{
//System.debug('after update　DailyReport.AcquisitionDays__c '+DailyReport.AcquisitionDays__c);
                        if(DailyReport.AcquisitionDays__c != null){
                            PaidTime = PaidTime + Kyosin7Setting.DailyReport_WorkingHours__c * Decimal.valueof(DailyReport.AcquisitionDays__c)*60;
                            AcquisitionDays = DailyReport.AcquisitionDays__c;
//System.debug('after update PaidTime1 '+PaidTime);
                        }
                        if(DailyReport.AcquisitionTime__c != null){
                            PaidTime = PaidTime + Decimal.valueof(DailyReport.AcquisitionTime__c)*60;
//System.debug('after update PaidTime2 '+PaidTime);
                        }
                        if(DailyReport.AcquisitionDays__c == null && DailyReport.DailyReportType__c == '有休'){
                            PaidTime = PaidTime + Kyosin7Setting.DailyReport_WorkingHours__c * 60;
                            AcquisitionDays = '1.0';
//System.debug('after update PaidTime3 '+PaidTime);
                        }
                    }
//System.debug('DailyReport__c after update PaidTime '+PaidTime);


                    // ---------------------------------------------------------------------------------------------------------------------------
                    // 打刻_時間入力種別が入力アシストの場合、出勤時間(選択)、退勤時間(選択)から算出
                    // 打刻_時間入力種別が入力アシスト以外の場合、出勤時間、退勤時間から算出
                    // 日報OBJの退勤時間および出勤時間に値が入っている場合に算出処理する
                    // ---------------------------------------------------------------------------------------------------------------------------
                    if(Kyosin7Setting.TimeStamp_TimeInputType__c == '入力アシスト'){
                        // 退勤時間(選択)および出勤時間(選択)に値が入っている場合
                        if(DailyReport.LeavingTimeSelection__c != null && DailyReport.AttendanceTimeSelection__c != null){

                            // 出社時間を取得
                            String[] StartDate = DailyReport.AttendanceTimeSelection__c.split(':',0);
                            StartTotalTime = (Integer.valueOf(StartDate[0])*60) + Integer.valueOf(StartDate[1]);
//System.debug('DailyReport__c after update StartTotalTime '+StartTotalTime);

                            // 退社時間を取得
                            String[] EndDate = DailyReport.LeavingTimeSelection__c.split(':',0);
                            if(EndDate[0].left(1)=='翌'){
                                EndTotalTime = (Integer.valueOf(EndDate[0].replace('翌', ''))*60) + Integer.valueOf(EndDate[1]) + 24*60;
                            }else{
                                EndTotalTime = (Integer.valueOf(EndDate[0])*60) + Integer.valueOf(EndDate[1]);
                            }
//System.debug('DailyReport__c after update EndTotalTime '+EndTotalTime);
                        }
                    }
                    // 打刻_時間入力種別が入力アシスト以外
                    else{
                        // 退勤時間および出勤時間に値が入っている場合
                        if(DailyReport.LeavingTime__c != null && DailyReport.AttendanceTime__c != null){
                            // 出社時間を取得
                            StartTotalTime = (DailyReport.AttendanceTime__c.hour()*60) + DailyReport.AttendanceTime__c.minute();
//System.debug('DailyReport__c after update StartTotalTime 22 '+StartTotalTime);

                            // 退社時間を取得
                            // [システム]選択時間が打刻_前日の勤務に含める退社時間以下の場合
                            // 24時間プラス
                            if(DailyReport.LeavingTime__c.hour() < Kyosin7Setting.TimeStamp_BeforeWorkingHours__c ||
                                (DailyReport.LeavingTime__c.hour() == Kyosin7Setting.TimeStamp_BeforeWorkingHours__c &&
                                DailyReport.LeavingTime__c.minute() == 0)){
                                EndTotalTime = (DailyReport.LeavingTime__c.hour()*60) + DailyReport.LeavingTime__c.minute() + 24*60;
                            }
                            else{
                                EndTotalTime = (DailyReport.LeavingTime__c.hour()*60) + DailyReport.LeavingTime__c.minute();
                            }
//System.debug('DailyReport__c after update EndTotalTime 22 '+EndTotalTime);
                        }
                    }

                        // ----------------------------------------------------------------------------------
                        // 労働時間（分）を算出
                        // ----------------------------------------------------------------------------------
                        // 労働時間＝退勤時間ー出勤時間ー休憩時間ー中抜け時間(有休時間は含まない)
                        WorkTime = EndTotalTime - StartTotalTime - BreakTime - NakanukeTime;
//System.debug('DailyReport__c after update WorkTime '+WorkTime);
//System.debug('after update BreakTimeSelection__c '+DailyReport.BreakTimeSelection__c);

                        //　----------------------------------------------------------------------------------
                        //　休憩時間が設定されていない場合、労働時間（分）より算出
                        //　労働時間（分）が８時間以上は６０分
                        //　労働時間（分）が6時間以上8時間未満は45分
                        //　----------------------------------------------------------------------------------
                        //　設定されている休憩時間が0の場合に処理する
                        if(DailyReport.BreakTimeSelection__c == '0' || DailyReport.BreakTimeSelection__c == null){
                            if(WorkTime >= 540){
                                BreakTime = 60;
                                BreakTimeSTR = '1.0';
                                WorkTime = EndTotalTime - StartTotalTime - BreakTime - NakanukeTime;
                            }
                            else if(WorkTime >= 420){
                                BreakTime = 45;
                                BreakTimeSTR = '0.75';
                                WorkTime = EndTotalTime - StartTotalTime - BreakTime - NakanukeTime;
                            }
                        }
//System.debug('DailyReport__c after　update　BreakTime2　'+BreakTime);

                        // ----------------------------------------------------------------------------------
                        // 時間外（分）を算出（労働時間+有休時間ー時間外時間より算出）
                        // ----------------------------------------------------------------------------------
                        // 労働時間＋有休時間ー勤務時間が正数の場合に算出
                        if((WorkTime + PaidTime - (Kyosin7Setting.DailyReport_WorkingHours__c*60)) > 0){
                            OverTime = WorkTime + PaidTime - (Kyosin7Setting.DailyReport_WorkingHours__c*60);
                        }

                        //----------------------------------------------------------------------------------
                        // 深夜時間（分）を算出（労働時間より算出）
                        // ----------------------------------------------------------------------------------
                        Decimal MTSTR = Kyosin7Setting.DailyReport_MidnightStartTime__c*60;
                        Decimal MTEND = (24+Kyosin7Setting.DailyReport_MidnightEndTime__c)*60;

                        // 出勤時間が0時から深夜終了時間内であれば出勤時間と退勤時間は24時間プラスして算出
                        if(0 <= StartTotalTime && StartTotalTime <= Kyosin7Setting.DailyReport_MidnightEndTime__c*60){
                            StartTotalTime = StartTotalTime + 24*60;
                            EndTotalTime = EndTotalTime + 24*60;
                        }
//System.debug('after update StartTotalTime '+StartTotalTime);
//System.debug('after update EndTotalTime '+EndTotalTime);

                        // 退勤時間が深夜終了時間以下の場合、深夜時間＝退勤時間ー出勤時間（IC打刻のみ）
                        if(EndTotalTime <= Kyosin7Setting.DailyReport_MidnightEndTime__c*60){
                            // 深夜時間＝退勤時間ー出勤時間
                            MidnightTime = EndTotalTime - StartTotalTime;
                        }

                        // 退勤時間>深夜開始時間かつ出勤時間>深夜開始時間かつ退勤時間>深夜終了時間の場合
                        if(EndTotalTime > MTSTR && StartTotalTime > MTSTR && EndTotalTime > MTEND){
                            // 深夜時間＝退勤終了時間ー出勤時間
                            MidnightTime = MTEND - StartTotalTime;
                        }
                        // 退勤時間>深夜開始時間かつ出勤時間>深夜開始時間かつ退勤時間<=深夜終了時間の場合
                        if(EndTotalTime > MTSTR && StartTotalTime > MTSTR && EndTotalTime <= MTEND){
                            // 深夜時間＝退勤時間ー出勤時間
                            MidnightTime = EndTotalTime - StartTotalTime;
                        }
                        // 退勤時間>深夜開始時間かつ出勤時間<=深夜開始時間かつ退勤時間>深夜終了時間の場合
                        if(EndTotalTime > MTSTR && StartTotalTime <= MTSTR && EndTotalTime > MTEND){
                            // 深夜時間＝退勤終了時間ー出勤開始時間
                            MidnightTime = MTEND - MTSTR;
                        }
                        // 退勤時間>深夜開始時間かつ出勤時間<=深夜開始時間かつ退勤時間<=深夜終了時間の場合
                        if(EndTotalTime > MTSTR && StartTotalTime <= MTSTR && EndTotalTime <= MTEND){
                            // 深夜時間＝退勤時間ー出勤開始時間
                            MidnightTime = EndTotalTime - MTSTR;
                        }
                        // 退勤時間<=深夜開始時間かつ出勤時間>深夜開始時間かつ退勤時間>深夜終了時間の場合
                        if(EndTotalTime <= MTSTR && StartTotalTime > MTSTR && EndTotalTime > MTEND){
                            // 深夜時間＝退勤終了時間ー出勤時間
                            MidnightTime = MTEND - StartTotalTime;
                        }
//System.debug('DailyReport__c after update MidnightTime '+MidnightTime);


                    // ----------------------------------------------------------------------------------
                    // 外出時間（分）を算出
                    // （打刻の種別が戻りの作成日時ー打刻の種別が外出の作成日時）
                    // 打刻休憩時間（分）を算出
                    // （打刻の種別が休憩終了の作成日時ー打刻の種別が休憩開始の作成日時）
                    // ----------------------------------------------------------------------------------
//System.debug('DailyReport__c after update DailyReportId '+DailyReportId);
                    // 紐ついた打刻レコードを降順に取得（種別が外出と戻りのみ）
                    List<TimeStamp__c> TimeStampList = [SELECT Id, TimeStampType__c, CalculationTimeSelection__c, CreatedDate
                                                                                            FROM TimeStamp__c
                                                                                            WHERE DailyReportId__c = :DailyReportId
                                                                                            ORDER BY CreatedDate DESC];

//System.debug('DailyReport__c after update TimeStampList.size() '+TimeStampList.size());
                    // 取得数分繰り返し
                    for(integer i=0; TimeStampList.size()>i; i++){
                        // レコード取得
                        TimeStamp__c TimeStamp = TimeStampList.get(i);
//System.debug('DailyReport__c after update TimeStamp '+TimeStamp);

                        // 種別が戻りの場合
                        if(TimeStamp.TimeStampType__c == '戻り'){
                            // 戻りのタイムスタンプを分に変換
                            RTM = (TimeStamp.CalculationTimeSelection__c.hour()*60)+TimeStamp.CalculationTimeSelection__c.minute();

                            // 取得数分繰り返し
                            for(integer j=i; TimeStampList.size()>j; j++){
                                // レコード取得
                                TimeStamp__c TimeStamp2 = TimeStampList.get(j);
                                // 戻りのペア（種別が外出）を探す
                                if(TimeStamp2.TimeStampType__c == '外出'){
                                    // 外出のタイムスタンプを分に変換
                                    GTM = (TimeStamp2.CalculationTimeSelection__c.day() - TimeStamp.CalculationTimeSelection__c.day())*24*60;
                                    GTM = GTM + (TimeStamp2.CalculationTimeSelection__c.hour()*60)+TimeStamp2.CalculationTimeSelection__c.minute();
                                    // 打刻外出時間の算出（戻りのタイムスタンプー外出のタイムスタンプ）
                                    TSGoOutTime = TSGoOutTime + RTM - GTM;
                                    i = j;
//System.debug('after update i '+i);
//System.debug('DailyReport__c after update TSGoOutTime '+TSGoOutTime);
                                    break;
                                }
                            }
                        }
                        // 種別が休憩終了の場合
                        if(TimeStamp.TimeStampType__c == '休憩終了'){
                            // 休憩終了のタイムスタンプを分に変換
                            RTM = (TimeStamp.CalculationTimeSelection__c.hour()*60)+TimeStamp.CalculationTimeSelection__c.minute();

                            // 取得数分繰り返し
                            for(integer j=i; TimeStampList.size()>j; j++){
                                // レコード取得
                                TimeStamp__c TimeStamp2 = TimeStampList.get(j);
                                // 休憩終了のペア（種別が休憩開始）を探す
                                if(TimeStamp2.TimeStampType__c == '休憩開始'){
                                    // 休憩開始のタイムスタンプを分に変換
                                    GTM = (TimeStamp2.CalculationTimeSelection__c.day() - TimeStamp.CalculationTimeSelection__c.day())*24*60;
                                    GTM = GTM + (TimeStamp2.CalculationTimeSelection__c.hour()*60)+TimeStamp2.CalculationTimeSelection__c.minute();
                                    // 打刻休憩時間の算出（休憩終了のタイムスタンプー休憩開始のタイムスタンプ）
                                    TSBreakTime = TSBreakTime + RTM - GTM;
                                    i = j;
//System.debug('DailyReport__c after update TSBreakTime '+TSBreakTime);
                                    break;
                                }
                            }
                        }
                        // 種別が移動終了の場合
                        if(TimeStamp.TimeStampType__c == '移動終了'){
                            // 移動終了のタイムスタンプを分に変換
                            RTM = (TimeStamp.CalculationTimeSelection__c.hour()*60)+TimeStamp.CalculationTimeSelection__c.minute();

                            // 取得数分繰り返し
                            for(integer j=i; TimeStampList.size()>j; j++){
                                // レコード取得
                                TimeStamp__c TimeStamp2 = TimeStampList.get(j);
                                // 移動終了のペア（種別が移動開始）を探す
                                if(TimeStamp2.TimeStampType__c == '移動開始'){
                                    // 移動開始のタイムスタンプを分に変換
                                    GTM = (TimeStamp2.CalculationTimeSelection__c.day() - TimeStamp.CalculationTimeSelection__c.day())*24*60;
                                    GTM = GTM + (TimeStamp2.CalculationTimeSelection__c.hour()*60)+TimeStamp2.CalculationTimeSelection__c.minute();
                                    // 打刻移動時間の算出（移動終了のタイムスタンプー移動開始のタイムスタンプ）
                                    TSMoveTime = TSMoveTime + RTM - GTM;
                                    i = j;
//System.debug('DailyReport__c after update TSMoveTime '+TSMoveTime);
                                    break;
                                }
                            }
                        }
                        // 種別が作業終了の場合
                        if(TimeStamp.TimeStampType__c == '作業終了'){
                            // 作業終了のタイムスタンプを分に変換
                            RTM = (TimeStamp.CalculationTimeSelection__c.hour()*60)+TimeStamp.CalculationTimeSelection__c.minute();

                            // 取得数分繰り返し
                            for(integer j=i; TimeStampList.size()>j; j++){
                                // レコード取得
                                TimeStamp__c TimeStamp2 = TimeStampList.get(j);
                                // 作業終了のペア（種別が作業開始）を探す
                                if(TimeStamp2.TimeStampType__c == '作業開始'){
                                    // 作業開始のタイムスタンプを分に変換
                                    GTM = (TimeStamp2.CalculationTimeSelection__c.day() - TimeStamp.CalculationTimeSelection__c.day())*24*60;
                                    GTM = GTM + (TimeStamp2.CalculationTimeSelection__c.hour()*60)+TimeStamp2.CalculationTimeSelection__c.minute();
                                    // 打刻作業時間の算出（作業終了のタイムスタンプー作業開始のタイムスタンプ）
                                    TSWorkTime = TSWorkTime + RTM - GTM;
                                    i = j;
//System.debug('DailyReport__c after update TSWorkTime '+TSWorkTime);
                                    break;
                                }
                            }
                        }
                    }

                    // ---------------------------------------------------------------------------------------------------------------------------
                    // 日報OBJの日報種別が”休日”,”代休”,”有休”,”欠勤”,”特休”のいずれかの場合
                    // 休憩時間、休憩時間(分)、出勤時間、退勤時間をクリアする
                    // ---------------------------------------------------------------------------------------------------------------------------
                    String AttendanceTimeSelection = DailyReport.AttendanceTimeSelection__c;
                    String LeavingTimeSelection = DailyReport.LeavingTimeSelection__c;
                    Datetime AttendanceTime = DailyReport.AttendanceTime__c;
                    Datetime LeavingTime = DailyReport.LeavingTime__c;
                    if(DailyReport.DailyReportType__c == '休日' || 
                        DailyReport.DailyReportType__c == '代休' || 
                        DailyReport.DailyReportType__c == '有休' || 
                        DailyReport.DailyReportType__c == '欠勤' || 
                        DailyReport.DailyReportType__c == '特休'){
                        // 休憩時間クリア
                        BreakTimeSTR = '';
                        // 休憩時間(分)クリア
                        BreakTime = 0;
                        // 出勤時間クリア
                        AttendanceTimeSelection = '';
                        AttendanceTime = null;
                        // 退勤時間クリア
                        LeavingTimeSelection = '';
                        LeavingTime = null;
                    }

                    // -----------------------------------------------------
                    // 日報データ更新処理
                    // -----------------------------------------------------    
                    // 日報OBJ
                    List<DailyReport__c> DailyReportListTMP = new List<DailyReport__c>();
                    // 更新データ設定
                    DailyReportListTMP.add(new DailyReport__c(
                                                                Id = DailyReport.Id,
                                                                AttendanceTime__c = AttendanceTime,
                                                                LeavingTime__c = LeavingTime,
                                                                BreakTimeSelection__c = BreakTimeSTR,
                                                                WorkTime__c = WorkTime,
                                                                BreakTime__c = BreakTime,
                                                                OverTime__c = OverTime,
                                                                MidnightTime__c = MidnightTime,
                                                                TSGoOutTime__c = TSGoOutTime,
                                                                TSBreakTime__c = TSBreakTime,
                                                                TSMoveTime__c = TSMoveTime,
                                                                TSWorkTime__c = TSWorkTime,
                                                                PaidTime__c = PaidTime,
                                                                AcquisitionDays__c = AcquisitionDays,
                                                                OwnerId = OwnID
                                                                )
                    );
                    // 日報OBJデータ更新
                    if(DailyReportListTMP.size() > 0){
                        try{
System.debug('DailyReport__c after update DailyReportListTMP2　'+DailyReportListTMP);
                            update DailyReportListTMP;
                        }catch(DmlException e){
                            System.debug('日報OBJの更新失敗');
                            Integer errNum = e.getNumDml();
                            for(Integer i = 0; i < errNum; i++){
                                DailyReportListTMP.get(e.getDmlIndex(i)).addError('日報データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                            }
                        }
                    }

//System.debug('after update DailyReport.AcquisitionDays__c　'+DailyReport.AcquisitionDays__c);
//System.debug('after update DailyReport_OLD.AcquisitionDays__c　'+DailyReport_OLD.AcquisitionDays__c);
//System.debug('after update DailyReport.AcquisitionTime__c　'+DailyReport.AcquisitionTime__c);
//System.debug('after update DailyReport_OLD.AcquisitionTime__c　'+DailyReport_OLD.AcquisitionTime__c);
//System.debug('after update MasterMemberListIdOLD　'+MasterMemberListIdOLD);
                    // ---------------------------------------------------------------------------------------------------------------
                    // 有休取得日数もしくは有休取得時間または
                    // 関連メンバーがNULLでなくかつ変更前と違う場合
                    // に有休残を算出
                    // ---------------------------------------------------------------------------------------------------------------
//                    if((DailyReport_OLD.AcquisitionDays__c != null && DailyReport.AcquisitionDays__c != DailyReport_OLD.AcquisitionDays__c) || 
//                        (DailyReport_OLD.AcquisitionTime__c != null && DailyReport.AcquisitionTime__c != DailyReport_OLD.AcquisitionTime__c) || 
                    if((DailyReport.AcquisitionDays__c != DailyReport_OLD.AcquisitionDays__c) || 
                        (DailyReport.AcquisitionTime__c != DailyReport_OLD.AcquisitionTime__c) || 
                        (MasterMemberListIdOLD != null && MasterMemberListId != MasterMemberListIdOLD)){

                        // ---------------------------------------------------------------------------------
                        // 関連メンバーが変更前と違う場合かつ
                        // 変更前の関連メンバーに値が入ってきる場合
                        // 変更前の有休残を加算する
                        // ---------------------------------------------------------------------------------    
                        if(MasterMemberListId != MasterMemberListIdOLD){
                            // 有休取得日数
                            Decimal DifferenceDays2 = 0;
                            if(DailyReport.AcquisitionDays__c != null)
                                DifferenceDays2 = 0 - Decimal.valueof(DailyReport.AcquisitionDays__c);

                            // 有休取得時間
                            Decimal DifferenceTime2 = 0;
                            if(DailyReport.AcquisitionTime__c != null)
                                DifferenceTime2 = 0 - Decimal.valueof(DailyReport.AcquisitionTime__c);

                            // 有給休暇OBJデータを取得(データロックされていないかつ年（期）の昇順)
                            List<PaidHolidays__c> PaidHolidaysList = [SELECT Id
                                                                                                        FROM PaidHolidays__c
                                                                                                        WHERE MasterMemberId__c = :MasterMemberListIdOLD
                                                                                                        AND DataLock__c = FALSE
                                                                                                        ORDER BY Period__c ASC];
							// データが取得できた場合
	                        if(PaidHolidaysList.size() > 0){

    	                        // レコード取得
        	                    PaidHolidays__c  PaidHolidays = PaidHolidaysList.get(0);
//System.debug('PaidHolidays 　'+PaidHolidays);
            	                // 有給休暇IDを設定
                	            ID PaidHolidaysIdOLD = PaidHolidays.Id;

                    	        // 有給休暇OBJ
                        	    List<PaidHolidays__c> PaidHolidayslistTMP0 = new List<PaidHolidays__c>();

	                            // 更新データ設定
    	                        PaidHolidayslistTMP0.add(new PaidHolidays__c(
        	                                                            Id = PaidHolidaysIdOLD,
            	                                                        DifferenceDays__c = DifferenceDays2,
                	                                                    DifferenceTime__c = DifferenceTime2,
                    	                                                TriggerUpdate__c = True,
                        	                                            PaidRequest__c = '申請'
                            	                                        )
                            	);
                            	// 有給休暇OBJデータ更新
	                            if(PaidHolidayslistTMP0.size() > 0) {
    	                            try{
System.debug('after update PaidHolidayslistTMP0 '+PaidHolidayslistTMP0);
        	                            update PaidHolidayslistTMP0;
            	                    }catch(DmlException e){
                	                    System.debug('after update old 有給休暇OBJの更新失敗');
                    	                Integer errNum = e.getNumDml();
                        	            for(Integer i = 0; i < errNum; i++){
                            	            PaidHolidayslistTMP0.get(e.getDmlIndex(i)).addError('変更前のメンバーの有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                                	    }
                                	}
                            	}
                        	}
	                        else{
    	                        // エラーメッセージ表示
        	                    for(DailyReport__c opp: Trigger.new){
            	                    opp.addError('変更前のメンバーの有給休暇OBJが存在していないため有休の残計算ができません！');
                	        	}
                            }
                        }

                        // -----------------------------------------------------
                        // 有給休暇データ更新処理
                        // -----------------------------------------------------    
                        // メンバーOBJ
                        List<PaidHolidays__c> PaidHolidayslistTMP = new List<PaidHolidays__c>();

                        // 差分計算（変更後の値ー変更前の値）
                        // 有休取得日数
                        Decimal DifferenceDays = 0;
                        if(DailyReport.AcquisitionDays__c != null)
                            DifferenceDays = Decimal.valueof(DailyReport.AcquisitionDays__c);
                        // 有休取得時間
                        Decimal DifferenceTime = 0;
                        if(DailyReport.AcquisitionTime__c != null)
                            DifferenceTime = Decimal.valueof(DailyReport.AcquisitionTime__c);
                        // 変更前の有休取得日数
                        if(AcquisitionDaysOld == null)
                            AcquisitionDaysOld = 0;
                        // 変更前の有休取得時間
                        if(AcquisitionTimeOld == null)
                            AcquisitionTimeOld = 0;
                        // 有休取得日数の差分
                        if(DifferenceDays != AcquisitionDaysOld)
                            DifferenceDays = DifferenceDays - AcquisitionDaysOld;
                        // 有休取得時間の差分
                        if(DifferenceTime != AcquisitionTimeOld)
                            DifferenceTime = DifferenceTime - AcquisitionTimeOld;

                        // 有給休暇OBJデータを取得(データロックされていないかつ年（期）の昇順)
                        List<PaidHolidays__c> PaidHolidaysList = [SELECT Id
                                                                                                    FROM PaidHolidays__c
                                                                                                    WHERE MasterMemberId__c = :MasterMemberListId
                                                                                                    AND DataLock__c = FALSE
                                                                                                    ORDER BY Period__c ASC];
						// データが取得できた場合
	                    if(PaidHolidaysList.size() > 0){

	                        // レコード取得
    	                    PaidHolidays__c  PaidHolidays = PaidHolidaysList.get(0);
        	                // 有給休暇IDを設定
            	            ID PaidHolidaysId = PaidHolidays.Id;

//System.debug('PaidHolidays 　'+PaidHolidays);
//System.debug('after update DifferenceDays '+DifferenceDays);
//System.debug('after update DifferenceTime '+DifferenceTime);

	                            // 更新データ設定
    	                    PaidHolidayslistTMP.add(new PaidHolidays__c(
        	                                                        Id = PaidHolidaysId,
            	                                                    DifferenceDays__c = DifferenceDays,
                	                                                DifferenceTime__c = DifferenceTime,
                    	                                            TriggerUpdate__c = True,
                        	                                        PaidRequest__c = '申請'
                            	                                    )
                        	);
	                        // 有給休暇OBJデータ更新
    	                    if (PaidHolidayslistTMP.size() > 0){
        	                    try{
System.debug('DailyReport__c after update PaidHolidayslistTMP '+PaidHolidayslistTMP);
            	                    update PaidHolidayslistTMP;
                	            }catch(DmlException e){
                    	            System.debug('after update有給休暇OBJの更新失敗');
                        	        Integer errNum = e.getNumDml();
                            	    for(Integer i = 0; i < errNum; i++){
                                	    PaidHolidayslistTMP.get(e.getDmlIndex(i)).addError('有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                                	}
                            	}
                        	}
                        }
                        else{
                            // エラーメッセージ表示
                            for(DailyReport__c opp: Trigger.new){
                                opp.addError('有給休暇OBJが存在していないため有休の残計算ができません！');
                        	}
                        }
                    }
                }
            }

        }

        // after delete処理
        if(Trigger.isAfter && Trigger.isDelete){
//System.debug('DailyReport__c after delete処理　');
        }

        // after undelete処理
        if(Trigger.isAfter && Trigger.isUnDelete){
//System.debug('DailyReport__c after undelete処理　');
        }

        // before insert処理
        if(Trigger.isBefore && Trigger.isInsert){
System.debug('DailyReport__c before insert処理　');
            // ----------------------------------------------------------------------
            // 日報レコード作成前に有休残をチェック
            //  ----------------------------------------------------------------------
            // 日報レコード取得
            List<DailyReport__c> DailyReportList = Trigger.new;
            DailyReport__c DailyReport = DailyReportList.get(0);

            // 日付を取得
            DATE DateTMP = DailyReport.Date__c;
            // 所有者を取得
            ID OwnerId = DailyReport.OwnerId;
            // 関連メンバーを取得
            ID MasterMemberId = DailyReport.MasterMemberId__c;
//System.debug('before insert Date '+DateTMP);
//System.debug('before insert OwnerId '+OwnerId);

            // 既に日報がある場合は作成できないエラーとする
            Decimal SIZE = 0;
            if(MasterMemberId == null){
                // 関連メンバーがNULLの場合は所有者で検索
                List<DailyReport__c> DailyReportList2 = [SELECT Id FROM DailyReport__c
                                                                                                            WHERE Date__c = :DateTMP
                                                                                                            AND OwnerId = :OwnerId];
                SIZE = DailyReportList2.size();
            }
            else{
                // 関連メンバーで検索
                List<DailyReport__c> DailyReportList2 = [SELECT Id FROM DailyReport__c
                                                                                                            WHERE Date__c = :DateTMP
                                                                                                            AND MasterMemberId__c = :MasterMemberId];
                SIZE = DailyReportList2.size();
            }
            // データが存在するか
            if(SIZE > 0){
                // エラーメッセージ表示
                for(DailyReport__c opp: Trigger.new){
                    opp.addError('日報データが存在しているため作成できません！');
                }
            }
            else{
                // --------------------------------------------------------------------------------------------
                // 日報OBJの有休取得日数または有休取得時間に値が入っている
                // または日報種別が有休の場合に処理する
                // --------------------------------------------------------------------------------------------
                if(DailyReport.AcquisitionDays__c != null || DailyReport.AcquisitionTime__c != null ||
                    DailyReport.DailyReportType__c == '有休'){

                    // 日報の所有者から関連メンバーを設定
                    ID MemberListId = null;
                    ID CRTID = DailyReport.OwnerId;
                    List<MasterMember__c> MasterMemberList = [SELECT Id, Name
                                                                                FROM MasterMember__c 
                                                                                WHERE UserId__c = :CRTID];
                    if(MasterMemberList.size() > 0){
                        MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                        MasterMemberId = MasterMemberSLT.Id;
//System.debug('Name　'+MemberSLT.Name);
//System.debug('AcquisitionDays__c　'+DailyReport.AcquisitionDays__c);
//System.debug('AcquisitionTime__c　'+DailyReport.AcquisitionTime__c);

                        // メンバーIDから有給休暇レコードを取得
                        // 有給休暇OBJデータを取得(年（期）の降順)
                        List<PaidHolidays__c> PaidHolidaysList = [SELECT Id,
                                                                                                                PaidLeaveRemainingDays__c, PaidLeaveRemainingTime__c,
                                                                                                                RemainingUntilNextGrant__c 
                                                                                                    FROM PaidHolidays__c
                                                                                                    WHERE MasterMemberId__c = :MasterMemberId
                                                                                                    AND DataLock__c = FALSE
                                                                                                    ORDER BY Period__c ASC];
                        if(PaidHolidaysList.size() > 0){
                            PaidHolidays__c PaidHolidaysSLT = PaidHolidaysList.get(0);
System.debug('DailyReport__c PaidHolidaysSLT　'+PaidHolidaysSLT);

                            // 有休取得日数を設定
                            Decimal AcquisitionDays = 0;
                            if(DailyReport.AcquisitionDays__c != null){
                                AcquisitionDays = decimal.valueof(DailyReport.AcquisitionDays__c);
                            }
                            // 有休取得時間を設定
                            Decimal AcquisitionTime = 0;
                            if(DailyReport.AcquisitionTime__c != null){
                                AcquisitionTime = decimal.valueof(DailyReport.AcquisitionTime__c);
                            }

                            // 有給休暇OBJの次回付与までの日数がマイナス（過去）の場合
                            if(PaidHolidaysSLT.RemainingUntilNextGrant__c  < 0){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得可能な期限が過ぎています！');
                                    }
                            }

                            // 日報OBJの有休取得日数が0以外の場合
                            if(DailyReport.AcquisitionDays__c != null){
                                // メンバーOBJの有休残(日数) < 日報OBJの有休取得日数の場合
                                if(PaidHolidaysSLT.PaidLeaveRemainingDays__c < decimal.valueof(DailyReport.AcquisitionDays__c)){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得可能な有休日数が不足しています！');
                                    }
                                }
                                // 日報OBJの有休取得日数が1日で有休取得時間が１以上の場合
                                if(AcquisitionDays == 1 && AcquisitionTime >= 1){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得合計が１日を超えています！');
                                    }
                                }
                                // 日報OBJの有休取得日数が0.5日で有休取得時間が5以上の場合
                                if(AcquisitionDays == 0.5 && AcquisitionTime >= 5){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得合計が１日を超えています！');
                                    }
                                }
                            }

                            // 日報OBJの有休取得時間が0以外の場合
                            if(DailyReport.AcquisitionTime__c != null){
                                // メンバーOBJの有休残(時間) < 日報OBJの有休取得時間の場合
                                if(PaidHolidaysSLT.PaidLeaveRemainingTime__c < decimal.valueof(DailyReport.AcquisitionTime__c)){
                                    // メンバーOBJの有休残(日数) が1以上ない場合
                                   if(PaidHolidaysSLT.PaidLeaveRemainingDays__c < 1){
                                       // エラーメッセージ表示
                                       for(DailyReport__c opp: Trigger.new){
                                           opp.addError('取得可能な有休時間が不足しています！');
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }

        // before update処理
        if(Trigger.isBefore && Trigger.isUpdate){
System.debug('DailyReport__c before update処理　');
            // ----------------------------------------------------------------------
            // 日報レコード更新前に有休残をチェック
            // ----------------------------------------------------------------------
            // 日報レコード取得
            List<DailyReport__c> DailyReportList = Trigger.new;
            DailyReport__c DailyReport = DailyReportList.get(0);

            // 変更前の日報レコード取得
            List<DailyReport__c> DailyReportListOLD = Trigger.old;
            DailyReport__c DailyReportOLD = DailyReportListOLD.get(0);

            // --------------------------------------------------------------------------------------------
                // 日報OBJの有休取得日数または有休取得時間に値が入っている
                // または日報種別が有休の場合に処理する
            // --------------------------------------------------------------------------------------------
            if(DailyReport.AcquisitionDays__c != null || DailyReport.AcquisitionTime__c != null ||
                    DailyReport.DailyReportType__c == '有休'){

                // --------------------------------------------------------------------------------------------
                // 有休取得日数または有休取得時間が変更前と違う
                // または日報種別が変更前と違う場合に処理する
                // --------------------------------------------------------------------------------------------
                if(DailyReport.AcquisitionDays__c != DailyReportOLD.AcquisitionDays__c || 
                    DailyReport.AcquisitionTime__c != DailyReportOLD.AcquisitionTime__c ||
                    DailyReport.DailyReportType__c != DailyReportOLD.DailyReportType__c){

                    // 日報の所有者から関連メンバーを設定
                    ID MasterMemberListId = null;
                    ID CRTID = DailyReport.OwnerId;
                    List<MasterMember__c> MasterMemberList = [SELECT Id, Name
                                                                                FROM MasterMember__c
                                                                                WHERE UserId__c = :CRTID];
                    if(MasterMemberList.size() > 0){
                        MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                        MasterMemberListId = MasterMemberSLT.Id;
//System.debug('Name　'+MemberSLT.Name);
//System.debug('AcquisitionDays__c　'+DailyReport.AcquisitionDays__c);
//System.debug('AcquisitionTime__c　'+DailyReport.AcquisitionTime__c);

                        // メンバーIDから有給休暇レコードを取得
                        // 有給休暇OBJデータを取得(年（期）の降順)
                        List<PaidHolidays__c> PaidHolidaysList = [SELECT Id,
                                                                                                                PaidLeaveRemainingDays__c, PaidLeaveRemainingTime__c,
                                                                                                                RemainingUntilNextGrant__c 
                                                                                                    FROM PaidHolidays__c
                                                                                                    WHERE MasterMemberId__c = :MasterMemberListId
                                                                                                    AND DataLock__c = FALSE
                                                                                                    ORDER BY Period__c ASC];
                        if(PaidHolidaysList.size() > 0){
                            PaidHolidays__c PaidHolidaysSLT = PaidHolidaysList.get(0);
System.debug('DailyReport__c PaidHolidaysSLT　'+PaidHolidaysSLT);


                            // 有休取得日数を設定
                            Decimal AcquisitionDays = 0;
                            if(DailyReport.AcquisitionDays__c != null){
                                AcquisitionDays = decimal.valueof(DailyReport.AcquisitionDays__c);
                            }
                            // 有休取得時間を設定
                            Decimal AcquisitionTime = 0;
                            if(DailyReport.AcquisitionTime__c != null){
                                AcquisitionTime = decimal.valueof(DailyReport.AcquisitionTime__c);
                            }

//System.debug('RemainingUntilNextGrant　'+PaidHolidaysSLT.RemainingUntilNextGrant__c);
                            // 有給休暇OBJの次回付与までの日数がマイナス（過去）の場合
                            if(PaidHolidaysSLT.RemainingUntilNextGrant__c  < 0){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得可能な日数が過ぎています！');
                                    }
                            }

                            // 日報OBJの有休取得日数が0以外の場合
                            if(DailyReport.AcquisitionDays__c != null){
                                // 有給休暇OBJの有休残日数 < 日報OBJの有休取得日数の場合
                                if(PaidHolidaysSLT.PaidLeaveRemainingDays__c < decimal.valueof(DailyReport.AcquisitionDays__c)){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得可能な有休日数が不足しています！');
                                    }
                                }
                                // 日報OBJの有休取得日数が1日で有休取得時間が１以上の場合
                                if(AcquisitionDays == 1 && AcquisitionTime >= 1){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得合計が１日を超えています！');
                                    }
                                }
                                // 日報OBJの有休取得日数が0.5日で有休取得時間が5以上の場合
                                if(AcquisitionDays == 0.5 && AcquisitionTime >= 5){
                                    // エラーメッセージ表示
                                    for(DailyReport__c opp: Trigger.new){
                                        opp.addError('取得合計が１日を超えています！');
                                    }
                                }
                            }

                            // 日報OBJの有休取得時間が0以外の場合
                            if(DailyReport.AcquisitionTime__c != null){
                                // 有給休暇OBJの有休残時間 < 日報OBJの有休取得時間の場合
                                if(PaidHolidaysSLT.PaidLeaveRemainingTime__c < decimal.valueof(DailyReport.AcquisitionTime__c)){
                                    // 有給休暇OBJの有休残日数 が1以上ない場合
                                    if(PaidHolidaysSLT.PaidLeaveRemainingDays__c < 1){
                                        // エラーメッセージ表示
                                        for(DailyReport__c opp: Trigger.new){
                                            opp.addError('取得可能な有休時間が不足しています！');
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // before delete処理
        if(Trigger.isBefore && Trigger.isDelete){
System.debug('DailyReport__c before delete処理　');
            // ----------------------------------------------------------------------
            // 日報レコード削除前に有休残を加算する
            // ----------------------------------------------------------------------
            // 日報レコード取得
            List<DailyReport__c> DailyReportList = Trigger.old;
            DailyReport__c DailyReportOld = DailyReportList.get(0);

            // --------------------------------------------------------------------------------------------
            // 日報OBJの有休取得日数または有休取得時間に値が入っている場合に処理する
            // --------------------------------------------------------------------------------------------
            if(DailyReportOld.AcquisitionDays__c != null || DailyReportOld.AcquisitionTime__c != null){

                // 日報の作成者から関連メンバーを設定
                ID MasterMemberListId = null;
                ID CRTID = DailyReportOld.CreatedById;
                List<MasterMember__c> MasterMemberList = [SELECT Id, Name
                                                                            FROM MasterMember__c
                                                                            WHERE UserId__c = :CRTID];
                if(MasterMemberList.size() > 0){
                    MasterMember__c MasterMemberSLT = MasterMemberList.get(0);
                    MasterMemberListId = MasterMemberSLT.Id;

                    // メンバーIDから有給休暇IDを取得
                    ID PaidHolidaysId = null;
                    List<PaidHolidays__c> PaidHolidaysList = [SELECT Id
                                                                                FROM PaidHolidays__c
                                                                                WHERE MasterMemberId__c = :MasterMemberListId
                                                                                AND DataLock__c = FALSE
                                                                                ORDER BY Period__c ASC];

                    PaidHolidays__c PaidHolidaysSLT = PaidHolidaysList.get(0);
                    PaidHolidaysId = PaidHolidaysSLT.Id;


                    // -----------------------------------------------------
                    // 有給休暇データ更新処理
                    // -----------------------------------------------------
                    // 有給休暇OBJ
                    List<PaidHolidays__c> PaidHolidaysTMP = new List<PaidHolidays__c>();

                    // 差分計算（変更後の値ー変更前の値）
                    // 有休日数
                    Decimal DifferenceDays = 0;
                    if(DailyReportOld.AcquisitionDays__c != null)
                        DifferenceDays = Decimal.valueof(DailyReportOld.AcquisitionDays__c);
                    //有休時間
                    Decimal DifferenceTime = 0;
                    if(DailyReportOld.AcquisitionTime__c != null)
                        DifferenceTime = Decimal.valueof(DailyReportOld.AcquisitionTime__c);
//System.debug('DifferenceDays(削除)　'+DifferenceDays);
//System.debug('DifferenceTime(削除)　'+DifferenceTime);

                    // 更新データ設定
                    PaidHolidaysTMP.add(new PaidHolidays__c(
                                                            Id = PaidHolidaysId,
                                                            DifferenceDays__c = DifferenceDays,
                                                            DifferenceTime__c = DifferenceTime,
                                                            TriggerUpdate__c = True,
                                                            PaidRequest__c = '削除'
                                                            )
                    );
                    // 有給休暇OBJデータ更新
                    if(PaidHolidaysTMP.size() > 0){
                        try{
System.debug('DailyReport__c PaidHolidaysTMP　'+PaidHolidaysTMP);
                            update PaidHolidaysTMP;
                        }catch(DmlException e){
                            System.debug('有給休暇OBJの更新失敗');
                            Integer errNum = e.getNumDml();
                            for(Integer i = 0; i < errNum; i++){
                                PaidHolidaysTMP.get(e.getDmlIndex(i)).addError('有給休暇データ更新時にエラーが発生しました'+e.getDmlMessage(i));
                            }
                        }
                    }
                }
            }
        }

    }
}
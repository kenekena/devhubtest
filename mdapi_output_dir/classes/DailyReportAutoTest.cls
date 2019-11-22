@isTest
public class DailyReportAutoTest {

    // 登録時のテスト(時間休)
    @isTest static void test_create1(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt1 = CreateDailyReport1();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt1, false);        
        Test.stopTest();
    }

    // 登録時のテスト(有休)
    @isTest static void test_create2(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt2 = CreateDailyReport2();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt2, false);        
        Test.stopTest();
    }

    // 登録時のテスト(有休エラー)
    @isTest static void test_create3(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt3 = CreateDailyReport3();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt3, false);        
        Test.stopTest();
    }

    // 登録時のテスト(有休エラー)
    @isTest static void test_create4(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt4 = CreateDailyReport4();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt4, false);        
        Test.stopTest();
    }

    // 登録時のテスト(有休エラー)
    @isTest static void test_create5(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt5 = CreateDailyReport5();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt5, false);        
        Test.stopTest();
    }

    // 登録時のテスト(深夜跨がり)
    @isTest static void test_create6(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt6 = CreateDailyReport6();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt6, false);        
        Test.stopTest();
    }

    // 登録時のテスト(種別：有休)
    @isTest static void test_create7(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt7 = CreateDailyReport7();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insDrt7, false);        
        Test.stopTest();
    }

    // 更新時のテスト(時間休：有休時間、退勤時間を変更)
    @isTest static void test_update1(){
        // テストデータ作成
        // 日報データ
        DailyReport__c updDrt1 = UpdateDailyReport1();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.update(updDrt1, false);
        Test.stopTest();
    }

    // 更新時のテスト(関連メンバーを変更)
    @isTest static void test_update2(){
        // テストデータ作成
        // 日報データ
        DailyReport__c updDrt1 = UpdateDailyReport2();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.update(updDrt1, false);
        Test.stopTest();
    }

    // 更新時のテスト(種別を変更)
    @isTest static void test_update3(){
        // テストデータ作成
        // 日報データ
        DailyReport__c updDrt1 = UpdateDailyReport3();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.update(updDrt1, false);
        Test.stopTest();
    }

    // 更新時のテスト(打刻)
    @isTest static void test_update4(){
        // テストデータ作成
        // 日報データ
        DailyReport__c updDrt1 = UpdateDailyReport4();

        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.update(updDrt1, false);
        Test.stopTest();
    }

    // 削除時のテスト
    @isTest static void test_delete1(){
        // テストデータ作成
        // 日報データ
        DailyReport__c delDrt1 = DeleteDailyReport1();
        
        // テスト開始
        Test.startTest();
        delete(delDrt1);
        Test.stopTest();
        
    }    


    // 日報テストデータ作成（出勤：平日勤務、時間休、時間外、深夜時間）
    private static DailyReport__c   CreateDailyReport1(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10,
            PaidLeaveRemainingTime__c = 0,
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 9, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 22, 30, 0);

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = EndDate,
            AttendanceTimeSelection__c = '9:00',
            LeavingTimeSelection__c = '22:30',
            AcquisitionTime__c = '2',
            OwnerId = USRID
        );
        return drt;
    }

    // 日報テストデータ更新（有休）
    private static DailyReport__c   CreateDailyReport2(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10.5,
            PaidLeaveRemainingTime__c = 1,
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '出勤',
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '4',
            BreakTimeSelection__c = '1.0',
            OwnerId = USRID
        );
        return drt;
    }

    
    // 日報テストデータ更新（有休エラー）
    private static DailyReport__c   CreateDailyReport3(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10,
            PaidLeaveRemainingTime__c = 0,
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '出勤',
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '7',
            BreakTimeSelection__c = '1.0',
            OwnerId = USRID
        );
        return drt;
    }

    // 日報テストデータ更新（有休エラー）
    private static DailyReport__c   CreateDailyReport4(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10,
            PaidLeaveRemainingTime__c = 0,
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '出勤',
            AcquisitionDays__c = '1.0',
            AcquisitionTime__c = '1',
            BreakTimeSelection__c = '1.0',
            OwnerId = USRID
        );
        return drt;
    }

    // 日報テストデータ更新（有休エラー）
    private static DailyReport__c   CreateDailyReport5(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember2();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10,
            PaidLeaveRemainingTime__c = 0,
            CarryForwardDays__c = 0,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '出勤',
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '7',
            BreakTimeSelection__c = '1.0',
            OwnerId = USRID
        );
        return drt;
    }

    // 日報テストデータ作成（出勤：深夜跨がり勤務、時間外、深夜時間）
    private static DailyReport__c   CreateDailyReport6(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10,
            PaidLeaveRemainingTime__c = 0,
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 9, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day()+1, 9, 30, 0);

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = EndDate,
            AttendanceTimeSelection__c = '9:00',
            LeavingTimeSelection__c = '翌9:30',
            BreakTimeSelection__c = '1.0',
            OwnerId = USRID
        );
        return drt;
    }

    // 日報テストデータ作成（有休）
    private static DailyReport__c   CreateDailyReport7(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;

        // 有給休暇データ作成
        PaidHolidays__c phd = new PaidHolidays__c(
            Period__c = '2019',
            GrantDays__c = 10,
            PaidLeaveRemainingDays__c = 10,
            PaidLeaveRemainingTime__c = 0,
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            RemainingGrantDays__c = 10,
            RemainingGrantTime__c = 0,
            MasterMemberId__c = MNBID
        );
        insert phd;

        // 本日を設定
        Date TDY = Date.today();        
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 9, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day()+1, 9, 30, 0);

        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            DailyReportType__c = '有休',
            BreakTimeSelection__c = '1.0',
            OwnerId = USRID
        );
        return drt;
    }


    
    // 日報テストデータ更新（出勤：翌日まで勤務、時間外、深夜時間）
    private static DailyReport__c   UpdateDailyReport1(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 日報データ作成
        DailyReport__c insDrt = CreateDailyReport1();
        insert insDrt;
        
        // 本日を設定
        Date TDY = Date.today();      
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 10, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 30, 0);

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
		Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
		while ((finishTime - startTime) < 1000) {
        	finishTime = DateTime.now().getTime();
    	}

        // データ更新
        DailyReport__c drt = new DailyReport__c(
            Id = insDrt.Id,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = StrDate,
            AttendanceTimeSelection__c = '10:00',
            LeavingTimeSelection__c = '23:30',
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '1',
            BreakTimeSelection__c = '1.0'
        );
        return drt;
    }

    // 日報テストデータ更新（出勤：翌日まで勤務、時間外、深夜時間）
    private static DailyReport__c   UpdateDailyReport2(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb2 = CreateMember();
        insert InsMnb2;
        String MNBID2 = InsMnb2.Id;

        // 日報データ作成
        DailyReport__c insDrt = CreateDailyReport1();
        insert insDrt;
        
        // 本日を設定
        Date TDY = Date.today();      
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 10, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 30, 0);

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
		Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
		while ((finishTime - startTime) < 1000) {
        	finishTime = DateTime.now().getTime();
    	}

        // データ更新
        DailyReport__c drt = new DailyReport__c(
            Id = insDrt.Id,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = EndDate,
            AttendanceTimeSelection__c = '10:00',
            LeavingTimeSelection__c = '23:30',
            MasterMemberId__c = MNBID2,
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '1',
            BreakTimeSelection__c = '1.0'
        );
        return drt;
    }

    // 日報テストデータ更新（有休⇒出勤）
    private static DailyReport__c   UpdateDailyReport3(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb2 = CreateMember();
        insert InsMnb2;
        String MNBID2 = InsMnb2.Id;

        // 日報データ作成
        DailyReport__c insDrt = CreateDailyReport7();
        insert insDrt;
        
        // 本日を設定
        Date TDY = Date.today();      
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 10, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 30, 0);

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
		Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
		while ((finishTime - startTime) < 1000) {
        	finishTime = DateTime.now().getTime();
    	}

        // データ更新
        DailyReport__c drt = new DailyReport__c(
            Id = insDrt.Id,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = EndDate,
            AttendanceTimeSelection__c = '10:00',
            LeavingTimeSelection__c = '23:30',
            MasterMemberId__c = MNBID2,
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '1',
            BreakTimeSelection__c = '1.0'
        );
        return drt;
    }

    // 日報テストデータ更新（打刻：戻り）
    private static DailyReport__c   UpdateDailyReport4(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // メンバーデータ作成
        MasterMember__c insMnb2 = CreateMember();
        insert InsMnb2;
        String MNBID2 = InsMnb2.Id;

        // 打刻データ作成
        TimeStamp__c insEbs0 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            TimeStampType__c = '出社打刻',
            AttendanceTimeSelection__c = '9:30',
            Comment__c = 'テスト'
        );
        insert insEbs0;
        
		List<TimeStamp__c> TimeStampList = [SELECT Id, DailyReportId__c
                                                                                FROM TimeStamp__c
                                                                                WHERE Comment__c = 'テスト'
                                                                                ORDER BY CreatedDate DESC];
        ID DailyReportId = null;
        for(integer i=0; TimeStampList.size()>i; i++){
        	// レコード取得
            TimeStamp__c TimeStamp = TimeStampList.get(i);
			// 日報IDを設定
			DailyReportId = TimeStamp.DailyReportId__c;
        }
System.debug('DailyReport__c TEST DailyReportId '+DailyReportId);
        

        // 打刻データ作成
        TimeStamp__c insEbs9 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '外出'
        );
        insert insEbs9;
        TimeStamp__c insEbs1 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '移動開始'
        );
        insert insEbs1;
        TimeStamp__c insEbs3 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '作業開始'
        );
        insert insEbs3;
        TimeStamp__c insEbs5 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '休憩開始'
        );
        insert insEbs5;

        // -----------------------------------------------------------
        // 3秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
		Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
		while ((finishTime - startTime) < 3000) {
        	finishTime = DateTime.now().getTime();
    	}


        TimeStamp__c insEbs10 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '戻り'
        );
        insert insEbs10;
        TimeStamp__c insEbs2 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '移動終了'
        );
        insert insEbs2;
        TimeStamp__c insEbs4 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '作業終了'
        );
        insert insEbs4;
        TimeStamp__c insEbs6 = new TimeStamp__c(
            MasterMemberId__c = InsMnb2.Id,
            DailyReportId__c = DailyReportId,
            TimeStampType__c = '休憩終了'
        );
        insert insEbs6;

        
        // 本日を設定
        Date TDY = Date.today();      
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 10, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 30, 0);

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
//		startTime = DateTime.now().getTime();
//		finishTime = DateTime.now().getTime();
//		while ((finishTime - startTime) < 1000) {
//        	finishTime = DateTime.now().getTime();
//    	}

        // データ更新
        DailyReport__c drt = new DailyReport__c(
            Id = DailyReportId,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = EndDate,
            MasterMemberId__c = MNBID2,
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '1',
            BreakTimeSelection__c = '1.0'
        );
        return drt;
    }

    // 日報テストデータ削除
    private static DailyReport__c   DeleteDailyReport1(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 日報データ作成
        DailyReport__c insDrt = CreateDailyReport1();
        insert insDrt;
        
        // 本日を設定
        Date TDY = Date.today();      
        // 出勤時間
        Datetime StrDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 10, 00, 0);
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 30, 0);

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
		Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
		while ((finishTime - startTime) < 1000) {
        	finishTime = DateTime.now().getTime();
    	}

        // データ更新
        DailyReport__c drt = new DailyReport__c(
            Id = insDrt.Id,
            DailyReportType__c = '出勤',
            AttendanceTime__c = StrDate,
            LeavingTime__c = EndDate,
            AcquisitionDays__c = '0.5',
            AcquisitionTime__c = '1',
            BreakTimeSelection__c = '1.0'
        );

        DailyReport__c drtdel = [SELECT Id FROM DailyReport__c];

        return drtdel;
    }


    // メンバーテストデータ作成
    private static MasterMember__c  CreateMember(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        
        // データ作成
        MasterMember__c mnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        return mnb;
    }

    // メンバーテストデータ作成
    private static MasterMember__c  CreateMember2(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        
        // データ作成
        MasterMember__c mnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        return mnb;
    }

}
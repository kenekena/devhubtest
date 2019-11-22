@isTest
public with sharing class MonthlyReportControllerTest {
    
    @isTest static void test_MonthlyReportController() {
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY11 = Date.today();        

        // テストデータ作成
        // メンバーデータ
        MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            FixedOvertime__c = 20,
            UserId__c = USRID
        );
        insert InsMnb;
        
	    // 勤怠テストデータ
        MonthlyReport__c  InsPtm = new MonthlyReport__c (
            Name = '先月の給与',
            SalaryMonth__c = TDY11,
            MasterMemberId__c = InsMnb.Id,
            OwnerId = USRID
        );
        insert InsPtm;

	    // 有給休暇テストデータ
        PaidHolidays__c  InsPhd = new PaidHolidays__c (
            Period__c = '2019',
            GrantDate__c = TDY11,
            MasterMemberId__c = InsMnb.Id,
            GrantDays__c = 10,
            CarryForwardDays__c = 2,
            CarryForwardTime__c = 2,
            OwnerId = USRID
        );
        insert InsPhd;

	    // 日報テストデータ(本日)
        DailyReport__c InsDrt = new DailyReport__c(
            Date__c = TDY11,
            DailyReportType__c = '出勤',
            MasterMemberId__c = InsMnb.Id,
            WorkTime__c = 600,
            BreakTime__c = 60,
            OverTime__c = 60,
			PaidTime__c  = 60,
			MidnightTime__c = 60,
            MonthlyReportId__c = InsPtm.Id,
            OwnerId = USRID
        );
        insert InsDrt;

        DailyReport__c InsDrt2 = new DailyReport__c(
            Date__c = TDY11+1,
            DailyReportType__c = '出勤',
            MasterMemberId__c = InsMnb.Id,
            WorkTime__c = 600,
            BreakTime__c = 60,
            OverTime__c = 60,
			PaidTime__c  = 60,
			MidnightTime__c = 60,
            OwnerId = USRID
        );
        insert InsDrt2;

        DailyReport__c InsDrt3 = new DailyReport__c(
            Date__c = TDY11+2,
            DailyReportType__c = '休日',
            MasterMemberId__c = InsMnb.Id,
            OwnerId = USRID
        );
        insert InsDrt3;

        DailyReport__c InsDrt4 = new DailyReport__c(
            Date__c = TDY11+3,
            DailyReportType__c = '休日出勤',
            MasterMemberId__c = InsMnb.Id,
            WorkTime__c = 600,
            BreakTime__c = 60,
            OverTime__c = 60,
			PaidTime__c  = 60,
			MidnightTime__c = 60,
            OwnerId = USRID
        );
        insert InsDrt4;
        
        
        // テスト開始        
        Test.startTest();

        String result = null;
        result = MonthlyReportController.MonthlyReportAccounting( InsPtm.Id );
        result = MonthlyReportController.MonthlyReportAccounting( InsMnb.Id );

        Test.stopTest();
        
    }

}
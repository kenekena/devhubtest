@isTest
public class Lwc_Find_Attendance_ControllerTest {

    @isTest static void test_Lwc_Find_Attendance_Controller() {
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY11 = Date.today();
        TDY11 = TDY11 + 30;
        String SDY = String.Valueof(TDY11.year())+'-'+String.Valueof(TDY11.month())+'-'+String.Valueof(TDY11.day());
        Date TDY12 = TDY11 + 30;
        String SDY2 = String.Valueof(TDY12.year())+'-'+String.Valueof(TDY12.month())+'-'+String.Valueof(TDY12.day());

        // テストデータ作成
        // メンバーデータ
        MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            EmploymentState__c = '在職',
            Affiliation__c = '技術部',
            UserId__c = USRID
        );
        insert InsMnb;
        
        // 打刻データ
        TimeStamp__c InsTsp = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            MasterMemberId__c = InsMnb.Id
        );
        insert InsTsp;

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
            OwnerId = USRID
        );
        insert InsDrt;

        // 日報データ更新
        List<DailyReport__c> updateList = new List<DailyReport__c>();
        updateList.add(new DailyReport__c(
            Id = InsDrt.Id,
            DailyReportType__c = '出勤',
            AttendanceTimeSelection__c = '10:00',
            LeavingTimeSelection__c = '23:30',
            MasterMemberId__c = InsMnb.Id,
            BreakTimeSelection__c = '1.0')
        );

        // テスト開始        
        Test.startTest();

        Lwc_Find_Attendance_Controller.findMyMasterMember(USRID);

		Lwc_Find_Attendance_Controller.findMasterMember(InsMnb.Id);

		Lwc_Find_Attendance_Controller.findMasterMembers('技術部');

		Lwc_Find_Attendance_Controller.findMyDailyReport(SDY,InsMnb.Id);

		Lwc_Find_Attendance_Controller.findDailyReport(SDY,SDY2,InsMnb.Id);

		Lwc_Find_Attendance_Controller.upsertDailyReport(updateList);

		Lwc_Find_Attendance_Controller.findTimeStamp(InsDrt.Id);

		Lwc_Find_Attendance_Controller.findEvent(SDY,USRID);

        Test.stopTest();

    }
    
}
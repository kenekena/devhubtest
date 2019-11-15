@isTest
public class AttendanceControllerTest {

    @isTest static void test_AttendanceController() {
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY11 = Date.today();        

        // テストデータ作成
        // メンバーデータ
        MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            EmploymentState__c = '在職',
            UserId__c = USRID
        );
        insert InsMnb;
        
        // 打刻データ
        TimeStamp__c InsTsp = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            MasterMemberId__c = InsMnb.Id
        );
        insert InsTsp;
                
        
        // テスト開始        
        Test.startTest();

        AttendanceController.AttendanceStatus ();

        Test.stopTest();

    }
    
}
@isTest
public class attendanceStatusTest {

    @isTest static void test_attendanceStatus() {
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
        
        // メンバーデータ
        MasterMember__c InsMnb2 = new MasterMember__c(
            Name = 'テストメンバー2',
            EmploymentState__c = '在職'
        );
        insert InsMnb2;
        
        // 打刻データ
        TimeStamp__c InsTsp2 = new TimeStamp__c(
            TimeStampType__c = '外出',
            MasterMemberId__c = InsMnb2.Id
        );
        insert InsTsp2;
                
        
        // テスト開始        
        Test.startTest();

        attendanceStatus.findMember();

        Test.stopTest();

    }
    
}
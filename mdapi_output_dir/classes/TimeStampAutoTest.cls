@isTest
public class TimeStampAutoTest {

    // 登録時のテスト（出社打刻）日報データあり
    @isTest static void test_create1(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt = CreateDailyReport();
        insert InsDrt;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            AttendanceTimeSelection__c = '9:30',
            TimeInputType__c = '１５分刻み'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);        
        Test.stopTest();
    }

    // 登録時のテスト（出社打刻）日報データなし
    @isTest static void test_create2(){
        // 本日を設定
        Date TDY = Date.today();        
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 12, 0);

        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            AttendanceTimeSelection__c = '22:30',
            CalculationTimeSelection__c = EndDate,
            TimeInputType__c = '手入力'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);        
        Test.stopTest();
    }

    // 登録時のテスト（出社打刻）日報データあり
    @isTest static void test_create3(){
        // 本日を設定
        Date TDY = Date.today();        
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 12, 0);

        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt = CreateDailyReport();
        insert InsDrt;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            LeavingTimeSelection__c  = '19:30',
            CalculationTimeSelection__c = EndDate,
            TimeInputType__c = 'タイムスタンプ'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);
        Test.stopTest();
    }

    // 登録時のテスト（出社打刻）日報データなし
    @isTest static void test_create4(){
        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs2 = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            IcCard__c = True,
            MasterMemberId__c = InsMnb.Id,
            LeavingTimeSelection__c  = '翌2:30',
            TimeInputType__c = '30分刻み'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs2, false);
        Test.stopTest();
    }

    // 登録時のテスト（出社打刻）日報データなし
    @isTest static void test_create5(){
        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs2 = new TimeStamp__c(
            TimeStampType__c = '出社打刻',
            IcCard__c = True,
            MasterMemberId__c = InsMnb.Id,
            LeavingTimeSelection__c  = '翌2:30'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs2, false);
        Test.stopTest();
    }

    // 登録時のテスト（退社打刻）日報データあり
    @isTest static void test_create6(){
        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt = CreateDailyReport();
        insert InsDrt;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '退社打刻',
            AttendanceTimeSelection__c = '9:30',
            TimeInputType__c = '１５分刻み'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);        
        Test.stopTest();
    }

    // 登録時のテスト（退社打刻）日報データなし
    @isTest static void test_create7(){
        // 本日を設定
        Date TDY = Date.today();        
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 12, 0);

        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '退社打刻',
            AttendanceTimeSelection__c = '22:30',
            CalculationTimeSelection__c = EndDate,
            TimeInputType__c = '手入力'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);        
        Test.stopTest();
    }

    // 登録時のテスト（退社打刻）日報データあり
    @isTest static void test_create8(){
        // 本日を設定
        Date TDY = Date.today();        
        // 退勤時間
        Datetime EndDate = Datetime.newInstance(TDY.year(), TDY.month(), TDY.day(), 23, 12, 0);

        // テストデータ作成
        // 日報データ
        DailyReport__c insDrt = CreateDailyReport();
        insert InsDrt;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '退社打刻',
            LeavingTimeSelection__c  = '19:30',
            CalculationTimeSelection__c = EndDate,
            TimeInputType__c = 'タイムスタンプ'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);
        Test.stopTest();
    }

    // 登録時のテスト（退社打刻）日報データなし
    @isTest static void test_create9(){
        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs2 = new TimeStamp__c(
            TimeStampType__c = '退社打刻',
            IcCard__c = True,
            MasterMemberId__c = InsMnb.Id,
            LeavingTimeSelection__c  = '翌2:30',
            TimeInputType__c = '30分刻み'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs2, false);
        Test.stopTest();
    }

    // 登録時のテスト（退社打刻）日報データなし
    @isTest static void test_create10(){
        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs2 = new TimeStamp__c(
            TimeStampType__c = '退社打刻',
            IcCard__c = True,
            MasterMemberId__c = InsMnb.Id,
            LeavingTimeSelection__c  = '翌2:30'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs2, false);
        Test.stopTest();
    }

    // 登録時のテスト（出社打刻、退社打刻以外）
    @isTest static void test_create11(){
        // テストデータ作成
        // 従業員データ
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;

        // 打刻データ
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        TimeStamp__c insEbs1 = new TimeStamp__c(
            TimeStampType__c = '移動開始'
        );
        TimeStamp__c insEbs2 = new TimeStamp__c(
            TimeStampType__c = '移動終了'
        );
        TimeStamp__c insEbs3 = new TimeStamp__c(
            TimeStampType__c = '作業開始'
        );
        TimeStamp__c insEbs4 = new TimeStamp__c(
            TimeStampType__c = '作業終了'
        );
        TimeStamp__c insEbs5 = new TimeStamp__c(
            TimeStampType__c = '休憩開始'
        );
        TimeStamp__c insEbs6 = new TimeStamp__c(
            TimeStampType__c = '休憩終了'
        );
        TimeStamp__c insEbs7 = new TimeStamp__c(
            TimeStampType__c = '出社打刻'
        );
        TimeStamp__c insEbs8 = new TimeStamp__c(
            TimeStampType__c = '退社打刻'
        );
        TimeStamp__c insEbs9 = new TimeStamp__c(
            TimeStampType__c = '外出'
        );
        TimeStamp__c insEbs10 = new TimeStamp__c(
            TimeStampType__c = '戻り'
        );
        
        // テスト開始
        Test.startTest();
        Database.SaveResult result = Database.insert(insEbs1, false);
        result = Database.insert(insEbs2, false);
        result = Database.insert(insEbs3, false);
        result = Database.insert(insEbs4, false);
        result = Database.insert(insEbs5, false);
        result = Database.insert(insEbs6, false);
        result = Database.insert(insEbs7, false);
        result = Database.insert(insEbs8, false);
        result = Database.insert(insEbs9, false);
        result = Database.insert(insEbs10, false);
        Test.stopTest();
    }

    
    
    // 従業員テストデータ作成
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

    // 日報テストデータ作成
    private static DailyReport__c   CreateDailyReport(){
        // 本日を設定
        Date TDY = Date.today();        
        // メンバーデータ作成
        MasterMember__c insMnb = CreateMember();
        insert InsMnb;
        String MNBID = InsMnb.Id;
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();
        
        // データ作成
        DailyReport__c drt = new DailyReport__c(
            Date__c = TDY,
            MasterMemberId__c = MNBID,
            OwnerId = USRID
        );
        return drt;
    }
}
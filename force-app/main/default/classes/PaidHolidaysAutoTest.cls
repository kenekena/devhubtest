@isTest
public class PaidHolidaysAutoTest {

    // 作成テスト1
    @isTest static void test_create1(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd2 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2018',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd2;
        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 6,
            CarryOverTime__c =0,
            DataLock__c = FALSE
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.insert(phd3, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト11
    @isTest static void test_update11(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 1.0,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト12    
    @isTest static void test_update12(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0.5,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト13    
    @isTest static void test_update13(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12.0,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 10.5,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 1.0,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12.0,
            RemainingGrantTime__c = 1,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = -1.0,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト14    
    @isTest static void test_update14(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12.0,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 10.5,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 1.0,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12.0,
            RemainingGrantTime__c = 1,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = -0.5,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト15    
    @isTest static void test_update15(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 11.0,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 0,
            CarryForwardTime__c = 1,
            CarryOverDigestionDays__c = 0.5,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 11.0,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 1.0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = -0.5,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト21
    @isTest static void test_update21(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = 2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト22
    @isTest static void test_update22(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 5,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 5,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = 2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト23
    @isTest static void test_update23(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 2.5,
            CarryOverTime__c =6,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 14.5,
            PaidLeaveRemainingTime__c = 1,
            
            CarryForwardDays__c = 2.5,
            CarryForwardTime__c = 1,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =5,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = 3,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト24
    @isTest static void test_update24(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 6,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 1,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト25
    @isTest static void test_update25(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 1,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 11,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト26
    @isTest static void test_update26(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 10,
            CarryOverDays__c = 0,
            CarryOverTime__c =7,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 13.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =7,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 7,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 1,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト27
    @isTest static void test_update27(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 10,
            CarryOverDays__c = 0,
            CarryOverTime__c =7,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '申請',
            
            PaidLeaveRemainingDays__c = 13.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =7,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 7,
            GrantDigestionDays__c = 2,
            GrantDigestionTime__c = 1,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト31
    @isTest static void test_update31(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 1,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 11,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = 2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト32
    @isTest static void test_update32(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 10,
            CarryOverDays__c = 0,
            CarryOverTime__c =7,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 13.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =7,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 7,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 1,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = 2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト33
    @isTest static void test_update33(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 10,
            CarryOverDays__c = 0,
            CarryOverTime__c =7,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 13.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =7,
            
            RemainingGrantDays__c = 0,
            RemainingGrantTime__c = 1,
            GrantDigestionDays__c = 1.5,
            GrantDigestionTime__c = 1,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = 2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // 更新テスト34
    @isTest static void test_update34(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 1,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 11,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 1,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト35
    @isTest static void test_update35(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 0.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 14,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 1,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0.5,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト36
    @isTest static void test_update36(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 1.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 14,
            RemainingGrantTime__c = 1,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 1,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト37
    @isTest static void test_update37(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 1.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 14,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト38
    @isTest static void test_update38(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 1.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 0,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト39
    @isTest static void test_update39(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = FALSE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 1.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0.5,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 0,
            RemainingGrantTime__c = 1,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = -1.0,
            DifferenceTime__c = 0,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 更新テスト41
    @isTest static void test_update41(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
        // 有給休暇データ作成        
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 0.5,
            CarryOverTime__c =1,
            DataLock__c = TRUE
        );
        insert phd3;
        
        // -------------------------------------------------
        // 有給休暇データ更新
        // -------------------------------------------------
        PaidHolidays__c phd = new PaidHolidays__c(
			Id = phd3.Id,
            PaidRequest__c = '削除',
            
            PaidLeaveRemainingDays__c = 12.5,
            PaidLeaveRemainingTime__c = 7,
            
            CarryForwardDays__c = 1.5,
            CarryForwardTime__c = 7,
            CarryOverDigestionDays__c = 0,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 0,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0.5,
            GrantDigestionTime__c = 0,
            
            DifferenceDays__c = 0,
            DifferenceTime__c = -2,
            TriggerUpdate__c = True
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(phd, false);        

        // テスト終了
        Test.stopTest();

    }

    // 削除テスト１
    @isTest static void test_delete1(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY = Date.today();        

        // テストデータ作成
        // メンバーデータ
		MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;

        // -------------------------------------------------
        // 有給休暇データ作成
        // -------------------------------------------------
       PaidHolidays__c phd3 = new PaidHolidays__c(
            MasterMemberId__c = InsMnb.Id,
            Period__c = '2019',
            GrantDays__c = 12,
            CarryOverDays__c = 6,
            CarryOverTime__c =0,
            
            PaidLeaveRemainingDays__c = 18,
            PaidLeaveRemainingTime__c = 0,
            
            CarryForwardDays__c = 6,
            CarryForwardTime__c = 0,
            CarryOverDigestionDays__c = 5,
            CarryOverDigestionTime__c =0,
            
            RemainingGrantDays__c = 12,
            RemainingGrantTime__c = 0,
            GrantDigestionDays__c = 0,
            GrantDigestionTime__c = 0,
            
            DataLock__c = FALSE
        );
        insert phd3;
        
        ID PHDID = phd3.Id;

        // 有給休暇データを取得
        PaidHolidays__c phd3del = [SELECT Id FROM PaidHolidays__c WHERE Id = :PHDID];
        
        // テスト開始
        Test.startTest();

        delete(phd3del);

        // テスト終了
        Test.stopTest();
        
    }


}
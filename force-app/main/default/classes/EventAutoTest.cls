@isTest
public class EventAutoTest {

    // テスト1(作成)
    @isTest static void test_create(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY11 = Date.today();        
        Datetime SRTDT11 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 0, 0, 0);
        Datetime ENDDT11 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 9, 30, 0);
        Datetime SRTDT13 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 17, 30, 0);
        Datetime ENDDT13 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 23, 00, 0);
        // 本日+1を設定
        Date TDY21 = TDY11.addDays(+1);
        Datetime SRTDT21 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 0, 30, 0);
        Datetime ENDDT21 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 1, 30, 0);
        Datetime SRTDT23 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 16, 0, 0);
        Datetime ENDDT23 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 23, 30, 0);

        
        // テストデータ作成
        // メンバーデータ
        MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;
        
        // 日報テストデータ(本日+1)
        DailyReport__c InsDrt = new DailyReport__c(
            Date__c = TDY21,
            MasterMemberId__c = InsMnb.Id,
            OwnerId = USRID
        );
        insert InsDrt;

        // 行動データ
        Event evt11 = new Event(
            Subject = '行動作成トリガテスト11',
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt11;
        
        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt21 = new Event(
            Subject = '行動作成トリガテスト21',
            ActivityDate = TDY21,
            StartDateTime = SRTDT23,
            EndDateTime = ENDDT23,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt21;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        // -------------------------------------------------
        // 行動データ
        // -------------------------------------------------
        // データ作成
        Event evt = new Event(
            Subject = '行動作成トリガテスト',
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.insert(evt, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // テスト2(更新)
    @isTest static void test_update(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY11 = Date.today();        
        Datetime SRTDT11 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 0, 0, 0);
        Datetime ENDDT11 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 9, 30, 0);
        Datetime SRTDT12 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 13, 30, 0);
        Datetime ENDDT12 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 14, 30, 0);
        Datetime SRTDT13 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 21, 30, 0);
        Datetime ENDDT13 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 23, 00, 0);
        // 本日+1を設定
        Date TDY21 = TDY11.addDays(+1);
        Datetime SRTDT21 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 0, 30, 0);
        Datetime ENDDT21 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 1, 30, 0);
        Datetime SRTDT22 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 14, 00, 0);
        Datetime ENDDT22 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 15, 00, 0);
        Datetime SRTDT23 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 21, 0, 0);
        Datetime ENDDT23 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 23, 30, 0);
        // 本日-1を設定
        Date TDY31 = TDY11.addDays(-1);
        Datetime SRTDT31 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 0, 30, 0);
        Datetime ENDDT31 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 1, 30, 0);
        Datetime SRTDT32 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 14, 00, 0);
        Datetime ENDDT32 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 15, 00, 0);
        Datetime SRTDT33 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 21, 0, 0);
        Datetime ENDDT33 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 23, 30, 0);
        // 本日+2を設定
        Date TDY41 = TDY11.addDays(+2);
        Datetime SRTDT41 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 0, 30, 0);
        Datetime ENDDT41 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 1, 30, 0);
        Datetime SRTDT42 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 14, 00, 0);
        Datetime ENDDT42 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 15, 00, 0);
        Datetime SRTDT43 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 21, 0, 0);
        Datetime ENDDT43 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 23, 30, 0);

        
        // テストデータ作成
        // メンバーデータ
        MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;
        
        // 日報テストデータ(本日)
        DailyReport__c InsDrt = new DailyReport__c(
            Date__c = TDY11,
            MasterMemberId__c = InsMnb.Id,
            OwnerId = USRID
        );
        insert InsDrt;

        // 日報テストデータ(本日+1)
        DailyReport__c InsDrt2 = new DailyReport__c(
            Date__c = TDY21,
            MasterMemberId__c = InsMnb.Id,
            OwnerId = USRID
        );
        insert InsDrt2;
        ID DPTID = InsDrt2.Id;

        // 行動データ
        Event evt11 = new Event(
            Subject = '行動作成トリガテスト11',
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt11;
        
        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt21 = new Event(
            Subject = '行動作成トリガテスト21',
            ActivityDate = TDY21,
            StartDateTime = SRTDT23,
            EndDateTime = ENDDT23,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt21;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt22 = new Event(
            Subject = '行動作成トリガテスト22',
            ActivityDate = TDY21,
            StartDateTime = SRTDT22,
            EndDateTime = ENDDT22,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt22;
        
        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt23 = new Event(
            Subject = '行動作成トリガテスト23',
            ActivityDate = TDY21,
            StartDateTime = SRTDT23,
            EndDateTime = ENDDT23,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt23;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt31 = new Event(
            Subject = '行動作成トリガテスト31',
            ActivityDate = TDY31,
            StartDateTime = SRTDT33,
            EndDateTime = ENDDT33,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt31;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt33 = new Event(
            Subject = '行動作成トリガテスト33',
            ActivityDate = TDY31,
            StartDateTime = SRTDT31,
            EndDateTime = ENDDT31,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt33;
        
        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt41 = new Event(
            Subject = '行動作成トリガテスト41',
            ActivityDate = TDY41,
            StartDateTime = SRTDT41,
            EndDateTime = ENDDT41,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt41;
        
        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        // -------------------------------------------------
        // 行動データ
        // -------------------------------------------------
        // データ作成
        Event evt = new Event(
            Subject = '行動作成トリガテスト',
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt;
        ID EVTID = evt.Id;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        // データ変更
        Event evtup1 = new Event(
            Id = evt.Id,
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        update evtup1;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        // データ変更
        Event evtup2 = new Event(
            Id = evt.Id,
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = True,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        update evtup2;

        // 日報レコードを削除
        DailyReport__c drtdel = [SELECT Id FROM DailyReport__c WHERE Date__c = :TDY11];
        delete(drtdel);

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        // データ変更
        Event evtup = new Event(
            Id = evt.Id,
            ActivityDate = TDY11,
            StartDateTime = SRTDT11,
            EndDateTime = ENDDT11,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        
        // テスト開始
        Test.startTest();

        Database.SaveResult result = Database.update(evtup, false);        

        // テスト終了
        Test.stopTest();
        
    }

    // テスト（削除）
    @isTest static void test_delete(){
        // 現在のユーザIDを設定
        String USRID = UserInfo.getUserId();

        // 本日を設定
        Date TDY11 = Date.today();        
        Datetime SRTDT11 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 0, 0, 0);
        Datetime ENDDT11 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 9, 30, 0);
        Datetime SRTDT12 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 3, 30, 0);
        Datetime ENDDT12 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 6, 30, 0);
        Datetime SRTDT13 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 21, 30, 0);
        Datetime ENDDT13 = Datetime.newInstanceGMT(TDY11.year(), TDY11.month(), TDY11.day(), 23, 00, 0);
        // 本日+1を設定
        Date TDY21 = TDY11.addDays(+1);
        Datetime SRTDT21 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 0, 30, 0);
        Datetime ENDDT21 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 1, 30, 0);
        Datetime SRTDT22 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 3, 00, 0);
        Datetime ENDDT22 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 6, 00, 0);
        Datetime SRTDT23 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 21, 0, 0);
        Datetime ENDDT23 = Datetime.newInstanceGMT(TDY21.year(), TDY21.month(), TDY21.day(), 23, 30, 0);
        // 本日-1を設定
        Date TDY31 = TDY11.addDays(-1);
        Datetime SRTDT31 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 0, 30, 0);
        Datetime ENDDT31 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 1, 30, 0);
        Datetime SRTDT32 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 3, 00, 0);
        Datetime ENDDT32 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 6, 00, 0);
        Datetime SRTDT33 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 21, 0, 0);
        Datetime ENDDT33 = Datetime.newInstanceGMT(TDY31.year(), TDY31.month(), TDY31.day(), 23, 30, 0);

        
        // テストデータ作成
        // メンバーデータ
        MasterMember__c InsMnb = new MasterMember__c(
            Name = 'テストメンバー',
            UserId__c = USRID
        );
        insert InsMnb;
        
        // 日報テストデータ(本日+1)
        DailyReport__c InsDrt = new DailyReport__c(
            Date__c = TDY21,
            MasterMemberId__c = InsMnb.Id,
            OwnerId = USRID
        );
        insert InsDrt;

        // 行動データ
        Event evt11 = new Event(
            Subject = '行動作成トリガテスト11',
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt11;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }
        
        Event evt21 = new Event(
            Subject = '行動作成トリガテスト21',
            ActivityDate = TDY21,
            StartDateTime = SRTDT23,
            EndDateTime = ENDDT23,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt21;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt22 = new Event(
            Subject = '行動作成トリガテスト22',
            ActivityDate = TDY21,
            StartDateTime = SRTDT23,
            EndDateTime = ENDDT23,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt22;

        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        Event evt33 = new Event(
            Subject = '行動作成トリガテスト33',
            ActivityDate = TDY31,
            StartDateTime = SRTDT33,
            EndDateTime = ENDDT33,
            IsAllDayEvent = False,
            PreviousDayAction__c = True,
            OwnerId = USRID
        );
        insert evt33;
        
        // -----------------------------------------------------------
        // 1秒ウェイト（更新が早いため）
        // -----------------------------------------------------------
        startTime = DateTime.now().getTime();
        finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 1000) {
            finishTime = DateTime.now().getTime();
        }

        // -------------------------------------------------
        // 行動データ
        // -------------------------------------------------
        // データ作成
        Event evt = new Event(
            Subject = '行動作成トリガテスト',
            ActivityDate = TDY11,
            StartDateTime = SRTDT13,
            EndDateTime = ENDDT13,
            IsAllDayEvent = False,
            PreviousDayAction__c = False,
            OwnerId = USRID
        );
        insert evt;
        ID EVTID = evt.Id;

        // 行動データを取得
        Event evtdel = [SELECT Id, ActivityDate FROM Event WHERE Id = :EVTID];
        
        // テスト開始
        Test.startTest();

        delete(evtdel);

        // テスト終了
        Test.stopTest();
        
    }


}
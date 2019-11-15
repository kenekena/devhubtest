/* eslint-disable no-unused-vars */
/* eslint-disable default-case */
/* eslint-disable no-console */
import { LightningElement,track,wire,api } from 'lwc';

/* 共通jsの読み込み */
import { SetListValue,ChangeText,ChangeProcess } from 'c/commonJs';

/* 選択リストを取得 */
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

/* ポップアップメッセージ表示 */
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

/* レコード更新系 */
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';

import DAILYREPORT_OBJECT from '@salesforce/schema/DailyReport__c';
import ID_FIELD from '@salesforce/schema/DailyReport__c.Id'; 
import DATE_FIELD from '@salesforce/schema/DailyReport__c.Date__c'; 
import DAILYREPORTYPE from '@salesforce/schema/DailyReport__c.DailyReportType__c';
import A_TIMELISTTYPE from '@salesforce/schema/DailyReport__c.AttendanceTimeSelection__c';
import L_TIMELISTTYPE from '@salesforce/schema/DailyReport__c.LeavingTimeSelection__c';
import BREAKTIMETYPE from '@salesforce/schema/DailyReport__c.BreakTimeSelection__c';
import S_A_TIMELISTTYPE from '@salesforce/schema/DailyReport__c.ScheduledAttendanceTime__c';
import S_L_TIMELISTTYPE from '@salesforce/schema/DailyReport__c.ScheduledLeavingTime__c';
import MASTERMEMBER_FIELD from '@salesforce/schema/DailyReport__c.MasterMemberId__c';

import GetUserId from '@salesforce/user/Id';
import findDailyReport from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyDailyReport';
import findMyMasterMember from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyMasterMember';
import findMasterMember from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMasterMember';
import findMasterMembers from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMasterMembers';


const Today = new Date();
const TodayText = ChangeText(Today);
const TodayProcess = ChangeProcess(Today);
const UserId = GetUserId;


/* PubSub */
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

/* 検索 */
import AFFILAIATIONTYPE from '@salesforce/schema/MasterMember__c.Affiliation__c';
const AffiliationDefaultValue= "All";
const AffiliationDefaultLabel= "すべて";
const DefaultLabelBase = "未定";
const DefaultValueBase = "未定";


export default class DailyReportDaily extends LightningElement {
    @api MemberSearchMode;
    @wire(CurrentPageReference) pageRef;

    @track EditMode =false;
    @track erorrMes ="";

    @track SelectDate = Today;
    @track SelectDateProcess = TodayProcess;
    @track SelectDateText = TodayText;
    @track SelectUserId = UserId;
    @track Title = TodayText;

    @track MemberMasterInfo = [];
    @track DailyReportInfo = [];

    @track DailyReportTypeValue = "";
    @track AttendanceTimeValue = "";
    @track LeavingTimeValue = "";
    @track BreakTimeValue = "";
    @track ScheduledAttendanceTimeValue = "";
    @track ScheduledLeavingTimeValue = "";


    /***** 検索 */
    @track SelectAffiliation ="";
    @track SelectMember ="";
    @track MemberList =[];
    @track MemberList2 =[];
    FirstTimeOnly = false;

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: AFFILAIATIONTYPE
    })
    AffiliationListdefault({error, data}) {
        if (data) {
          //this.AffiliationList = data.values;
          this.AffiliationList = SetListValue(data,true,AffiliationDefaultValue,AffiliationDefaultLabel);
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'メンバー取得エラー',
                    message: error,
                    variant: 'error'
                })
            );
        }
    }

    /********************************
      アクション：部署選択リストを変更
      ⇒SearchMember()へ
    ********************************/
    ChangeAffiliation(event){
        this.load= false;
        this.SelectAffiliation = event.target.value;
        this.SearchMember();
    }

    /********************************
      メンバーを検索
    ********************************/
    SearchMember(){
        let i =0;
        let setMemberList = [];
        this.MemberList =[];
        this.MemberList2 =[];

        findMasterMembers({ Affiliation :this.SelectAffiliation})
        .then(result => {
            for(i = 0; i< result.length; i++){
                setMemberList[i] = {
                    value : result[i].Id,
                    label : result[i].Name,
                }
                this.MemberList2[result[i].Id] = result[i];
            }
            this.MemberList = setMemberList;
            if(this.FirstTimeOnly){
                this.SelectMember = "";
            }else{
                /* 最初は自分の名前を表示 */
                this.SelectMember = this.MemberMasterInfo.Id;
                this.FirstTimeOnly = true;
            }
            
            //console.log("■MemberList2");
            //console.log(this.MemberList2);
            //console.log(this.SelectMember);

        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'メンバー取得エラー',
                    message: error,
                    variant: 'error'
                })
            );
        })
    }

    
    

    /* ------------------------
        時間のリストを取得：初回のみ
    ------------------------ */
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: DAILYREPORTYPE
    })
    DailyReportTypeList;

    /* ------------------------
        時間のリストを取得：初回のみ
    ------------------------ */
    @track AttendanceTimeList =[];
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: A_TIMELISTTYPE
    })
    AttendanceTimeListdefault({error, data}) {
        if (data) {
            this.AttendanceTimeList = SetListValue(data,true,DefaultValueBase,DefaultLabelBase);
        }
    }

    /* ------------------------
        時間のリストを取得：初回のみ
    ------------------------ */
    @track LeavingTimeList =[];
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: L_TIMELISTTYPE
    })
    LeavingTimeListdefault({error, data}) {
        if (data) {
            this.LeavingTimeList = SetListValue(data,true,DefaultValueBase,DefaultLabelBase);
        }
    }
    /* ------------------------
        休憩時間を取得
    ------------------------ */
    @track BreakTimeList =[];
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: BREAKTIMETYPE
    })
    BreakTimeListdefault({error, data}) {
        if (data) {
            this.BreakTimeList = SetListValue(data,false);
        }
    }

    /* ------------------------
        予定出社時間を取得
    ------------------------ */
    @track ScheduledAttendanceTimeList = [];
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: S_A_TIMELISTTYPE
    })
    ScheduledAttendanceTimeListdefault({error, data}) {
        if (data) {
            this.ScheduledAttendanceTimeList = SetListValue(data,true,DefaultValueBase,DefaultLabelBase);
        }
    }

    /* ------------------------
        予定退社時間を取得
    ------------------------ */
    @track ScheduledLeavingTimeList = [];
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: S_L_TIMELISTTYPE
    })
    ScheduledLeavingTimeListdefault({error, data}) {
        if (data) {
            this.ScheduledLeavingTimeList = SetListValue(data,true,DefaultValueBase,DefaultLabelBase);
        }
    }


    connectedCallback() {
        findMyMasterMember({UserId : UserId})
        .then(result => {
            this.SelectMember = result[0].Id
            this.GetMasterMember();
        })
        
    }


    ChangeSelectDate(event){
        let num =0;

        if(event.target.dataset.type === "DateButton"){
            num = Number(event.target.value);
            if(num === 0 ){
                this.SelectDate = new Date();
            }else{
                this.SelectDate.setDate(this.SelectDate.getDate() + num);
            }
        }else if(event.target.dataset.type === "DateSelect"){
            this.SelectDate = new Date( event.target.value.substr(0,4),event.target.value.substr(5,2) -1,event.target.value.substr(8,2));
        }
        this.SelectDateProcess = ChangeProcess(this.SelectDate);
        this.SelectDateText = ChangeText(this.SelectDate);
        this.GetDailyReport();
    }

    ChangeMember(event){
        this.SelectMember = event.target.value;
        this.GetMasterMember();
    }

    GetMasterMember(){
        findMasterMember({MasterMemberId : this.SelectMember})
        .then(result => {
            this.MemberMasterInfo = result[0];
            if(this.MemberMasterInfo.Affiliation__c === undefined){
                this.SelectAffiliation = AffiliationDefaultValue;
            }else{
                this.SelectAffiliation = this.MemberMasterInfo.Affiliation__c;
            }
            if(this.MemberMasterInfo.Name === undefined){
                this.MemberMasterInfo.Name = "名無し";
            }
            this.SelectMember = this.MemberMasterInfo.Id;
            this.SelectUserId = this.MemberMasterInfo.UserId__c;
            /* 初回読み込み時、検索モードだったら自分の名前をデフォルトにする */
            if( this.MemberSearchMode && !this.FirstTimeOnly){ 
                //console.log("こここここここ");
                //console.log(this.SelectMember);
                //console.log(this.MemberMasterInfo.Name);
                this.SearchMember();
            }
            
            this.GetDailyReport();
        })
    }

    GetDailyReport(){
        //日報レコードがなかったら
        this.DailyReportInfo = [];
        //メンバーobj情報をもとに日報検索
        findDailyReport({
            SelectDateProcess : this.SelectDateProcess,
            MemberId : this.SelectMember
        })
            .then(result => {
                //日報レコードがなかったら
                //console.log(result);
                if(result.length === 0){
                    this.DailyReportInfo = {
                        Date__c : this.SelectDateProcess,
                        ScheduledAttendanceTime__c : "",
                        ScheduledLeavingTime__c : "",
                        AttendanceTime__c : "",
                        LeavingTime__c : "",
                        DisplayTimeStampAttendanceTime__c : "",
                        DisplayTimeStampLeavingTime__c : "",
                        DailyReportType__c : "",
                        BreakTimeSelection__c : "",
                        ActualTime__c : "",
                        OverTimeHour__c : "",
                        MidnightTimeHour__c : "",
                        HolidayWorkTime__c : "",
                        Id : undefined,
                    }
                    //選択リストのvalueをセット
                    this.DailyReportTypeValue ="";
                    this.AttendanceTimeValue ="";
                    this.LeavingTimeValue ="";
                    this.BreakTimeValue ="";
                    this.ScheduledAttendanceTimeValue = "";
                    this.ScheduledLeavingTimeValue = "";
                }else{
                    //空の項目 undefinedを空白で作成
                    if(result[0].DisplayTimeStampAttendanceTime__c ===undefined){result[0].DisplayTimeStampAttendanceTime__c=""}
                    if(result[0].DisplayTimeStampLeavingTime__c ===undefined){result[0].DisplayTimeStampLeavingTime__c=""}
                    if(result[0].MidnightTimeHour__c ===undefined){result[0].MidnightTimeHour__c=""}
                    if(result[0].ActualTime__c ===undefined){result[0].ActualTime__c=""}
                    if(result[0].OverTimeHour__c ===undefined){result[0].OverTimeHour__c=""}
                    if(result[0].HolidayWorkTime__c ===undefined){result[0].HolidayWorkTime__c=""}

                    this.DailyReportInfo = result[0];
                    //選択リストのvalueをセット
                    this.DailyReportTypeValue = this.DailyReportInfo.DailyReportType__c;
                    this.AttendanceTimeValue= this.DailyReportInfo.AttendanceTimeSelection__c;
                    this.LeavingTimeValue = this.DailyReportInfo.LeavingTimeSelection__c;
                    this.BreakTimeValue = this.DailyReportInfo.BreakTimeSelection__c;
                    this.ScheduledAttendanceTimeValue = this.DailyReportInfo.ScheduledAttendanceTime__c;
                    this.ScheduledLeavingTimeValue = this.DailyReportInfo.ScheduledLeavingTime__c;
                }
                    this.DailyReportInfo.DateText = this.SelectDateText;
                    this.Title = this.SelectDateText;
                    this.Send();
                    
            })
        }

    Send(){
        /* 他のComponnentに更新情報を送信 */
        let SendData = {
            Mode : "ChangeDate",
            MemberMasterInfo : this.MemberMasterInfo,
            SelectDate : this.SelectDate,
            SelectDateProcess : this.SelectDateProcess,
            SelectDateText : this.SelectDateText,
            SelectUserId : this.SelectUserId
        }
        fireEvent(this.pageRef, 'ChangeDaily',SendData);
    }


    /* 編集モードボタン */
    handleToggleClick(event) {
        this.EditMode = Number(event.target.value);
        this.erorrMes = "";
    }

    /* 項目を変更 */
    ChangeValue(event) {
        //console.log(event.target.name);
        switch( event.target.name ) {
            case 'DailyReportType':
                this.DailyReportTypeValue = event.target.value ;
                break;
            case 'AttendanceTime':
                this.AttendanceTimeValue = event.target.value ;
                break;
            case 'LeavingTime':
                this.LeavingTimeValue = event.target.value ;
                break;
            case 'BreakTime':
                this.BreakTimeValue = event.target.value ;
                break;
            case 'ScheduledAttendanceTime':
                this.ScheduledAttendanceTimeValue = event.target.value;
                break;
            case 'ScheduledLeavingTime':
                this.ScheduledLeavingTimeValue = event.target.value;
                break;
            default:
                break;
        }
    }

    Save() {
        const fields = {};
        if(this.DailyReportTypeValue === undefined||this.DailyReportTypeValue === ""){
            this.erorrMes = "種別を選択してください。";
            return;
        }
        //console.log("aaaaaaagagga");
        //console.log(this.MemberMasterInfo.Name);
        //console.log(this.MemberMasterInfo.Id);
        //console.log(this.SelectMember);

        //保存時にレコードが作成されていないかチェック
        findDailyReport({
            SelectDateProcess : this.SelectDateProcess,
            MemberId : this.SelectMember
        })
            .then(result => {
                //console.log(result);
                if(result.length === 0){
                    fields[ID_FIELD.fieldApiName] = undefined;
                    
                }else{
                    fields[ID_FIELD.fieldApiName] = result[0].Id;
                    //console.log("result[0].Id");
                    //console.log(result[0].Id);
                }
                fields[DATE_FIELD.fieldApiName] = this.SelectDateProcess;
                fields[DAILYREPORTYPE.fieldApiName] = this.DailyReportTypeValue;

                if(this.AttendanceTimeValue === DefaultValueBase){
                    fields[A_TIMELISTTYPE.fieldApiName] = "";
                }else{
                    fields[A_TIMELISTTYPE.fieldApiName] = this.AttendanceTimeValue;
                }
                if(this.LeavingTimeValue === DefaultValueBase){
                    fields[L_TIMELISTTYPE.fieldApiName] = "";
                }else{
                    fields[L_TIMELISTTYPE.fieldApiName] = this.LeavingTimeValue;
                }
                
                fields[BREAKTIMETYPE.fieldApiName] = this.BreakTimeValue;
                fields[MASTERMEMBER_FIELD.fieldApiName] = this.SelectMember;

                /* 出勤or休日出勤なら予定時間を自動入力 */
                /* 予定出社：空なら、メンバーマスタの定時時間をみる */
                if(this.ScheduledAttendanceTimeValue === "" || this.ScheduledAttendanceTimeValue === undefined){
                    //console.log("this.MemberList2[this.SelectMember].RegularTimeStart__c");
                    //console.log(this.MemberList2[this.SelectMember].RegularTimeStart__c);
                    //console.log("fields[ID_FIELD.fieldApiName]");
                    //console.log(fields[ID_FIELD.fieldApiName]);
                    
                    if( !(this.MemberList2[this.SelectMember].RegularTimeStart__c ==="" || this.MemberList2[this.SelectMember].RegularTimeStart__c === undefined) && fields[ID_FIELD.fieldApiName]=== undefined){//更新なら反映させない
                        if(this.DailyReportTypeValue === "出勤" || this.DailyReportTypeValue === "休日出勤"){
                            fields[S_A_TIMELISTTYPE.fieldApiName] = this.MemberList2[this.SelectMember].RegularTimeStart__c;
                        }
                    }
                }else{
                    if(this.ScheduledAttendanceTimeValue === DefaultValueBase){
                        fields[S_A_TIMELISTTYPE.fieldApiName] = "";
                    }else{
                        fields[S_A_TIMELISTTYPE.fieldApiName] = this.ScheduledAttendanceTimeValue;
                    }
                }

                /* 予定退社：空なら、メンバーマスタの定時時間をみる */
                if(this.ScheduledLeavingTimeValue === "" || this.ScheduledLeavingTimeValue === undefined){
                    if( !(this.MemberList2[this.SelectMember].RegularTimeEnd__c ==="" || this.MemberList2[this.SelectMember].RegularTimeEnd__c === undefined) && fields[ID_FIELD.fieldApiName] === undefined){//更新なら反映させない
                        if(this.DailyReportTypeValue === "出勤" || this.DailyReportTypeValue === "休日出勤"){
                            fields[S_L_TIMELISTTYPE.fieldApiName] = this.MemberList2[this.SelectMember].RegularTimeEnd__c;
                        }
                    }
                }else{
                    if(this.ScheduledLeavingTimeValue === DefaultValueBase){
                        fields[S_L_TIMELISTTYPE.fieldApiName] = "";
                    }else{
                        fields[S_L_TIMELISTTYPE.fieldApiName] = this.ScheduledLeavingTimeValue;
                    }
                    
                }
                /* END:出勤or休日出勤なら予定時間を自動入力 */


                
                //console.log("this.AttendanceTimeValue");
                //console.log(this.DailyReportTypeValue);
                //console.log(this.AttendanceTimeValue);
                //console.log(this.LeavingTimeValue);
                //console.log(this.DailyReportTypeValue);

                 /* IDを見て、新規作成か更新か */
                if(fields[ID_FIELD.fieldApiName] === 'false' || fields[ID_FIELD.fieldApiName] === undefined){
                    /* 新規作成 */
                    const recordInput = {apiName: DAILYREPORT_OBJECT.objectApiName, fields };
                    createRecord(recordInput)
                        .then(() => {
                                this.GetDailyReport();
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: '成功',
                                        message: '作成しました',
                                        variant: 'success',
                                    }) 
                                );
                                this.EditMode = false;
                        })
                        .catch(() => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'レコード作成エラー',
                                    message: '',
                                    variant: 'error',
                                }),
                            );
                            
                        });
                }else{
                    /* 更新 */
                    const recordInput = { fields };
                    updateRecord(recordInput)
                    .then(() => {
                            this.GetDailyReport();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: '成功',
                                    message: '更新しました',
                                    variant: 'success',
                                }),
                            );
                            this.EditMode = false;
                    })
                    .catch(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'レコード更新エラー',
                                message: '',
                                variant: 'error',
                            }),
                        );
                        
                    });
                }


            



            })
    }





}
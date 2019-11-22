/* eslint-disable default-case */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable no-alert */
import { LightningElement,track,wire,api } from 'lwc';
/* 共通jsの読み込み */
import { SetListValue,ChangeText,ChangeProcess } from 'c/commonJs';

import GetUserId from '@salesforce/user/Id';

import findMyMasterMember from '@salesforce/apex/Lwc_Find_Attendance_Controller.findMyMasterMember';

/* ポップアップメッセージ表示 */
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

/* レコード更新系 */
import { createRecord } from 'lightning/uiRecordApi';

import TIMESTAMP_OBJECT from '@salesforce/schema/TimeStamp__c';
import TIMESTAMPTYPE_FIELD from '@salesforce/schema/TimeStamp__c.TimeStampType__c';
import T_MEMBERID_FIELD from '@salesforce/schema/TimeStamp__c.MasterMemberId__c';
import T_ATTENDANCE_FIELD from '@salesforce/schema/TimeStamp__c.AttendanceTimeSelection__c';
import T_LEAVING_FIELD from '@salesforce/schema/TimeStamp__c.LeavingTimeSelection__c';
import T_COMMENT_FIELD from '@salesforce/schema/TimeStamp__c.Comment__c';

/* PubSub */
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

const Today = new Date();
const TodayText = ChangeText(Today);
const TodayProcess = ChangeProcess(Today);
const UserId = GetUserId;


export default class TimestampButtons extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api SimpleTimeStampMode = 1;

    @track MemberMasterInfo = [];
    @track move = false;@track work = false;@track outoffice = false;
    @track rest = false;@track Leaving = false;@track Attendance = false;
    @track moveClass = "btn-push";@track workClass = "btn-push";@track outofficeClass = "btn-push";
    @track restClass = "btn-push";@track LeavingClass = "btn-push btn-blue";@track AttendanceClass = "btn-push btn-blue";

    /* ポップアップ用 */
    @track loading = false;
    @track openmodel = false;
    @track AttendanceOpen = true;

    /* 出退勤 */
    @track AttendanceTimeValue;
    @track LeavingTimeValue;
    @track CommentValue;

    connectedCallback() {
        this.GetMasterMember();
    }

    GetMasterMember(){
        findMyMasterMember({UserId : UserId})
        .then(result => {
            console.log(result[0]);
            this.MemberMasterInfo = result[0];
            /* ボタンの色を設定 */
            if(this.MemberMasterInfo.ArrivalStatus__c===false){
                this.move = true;
                this.moveClass = "btn-push-disabled";
                this.work = true;
                this.workClass = "btn-push-disabled";
                this.outoffice = true;
                this.outofficeClass = "btn-push-disabled";
                this.rest = true;
                this.restClass = "btn-push-disabled";
                this.Leaving = true;
                this.LeavingClass = "btn-push-disabled";
                this.Attendance = false;
                this.AttendanceClass = "btn-push btn-blue";
            }else{
                // eslint-disable-next-line default-case
                switch( this.MemberMasterInfo.WorkingStatus__c ) {
                    case '休憩中':
                        this.move = true;
                        this.moveClass = "btn-push-disabled";
                        this.work = true;
                        this.workClass = "btn-push-disabled";
                        this.outoffice = true;
                        this.outofficeClass = "btn-push-disabled";
                        this.rest = false;
                        this.restClass = "btn-push";
                        this.Leaving = true;
                        this.LeavingClass = "btn-push-disabled";
                        this.Attendance = true;
                        this.AttendanceClass = "btn-push-disabled";
                        break;
                    case '移動中':
                        this.move = false;
                        this.moveClass = "btn-push";
                        this.work = true;
                        this.workClass = "btn-push-disabled";
                        this.outoffice = true;
                        this.outofficeClass = "btn-push-disabled";
                        this.rest = true;
                        this.restClass = "btn-push-disabled";
                        this.Leaving = true;
                        this.LeavingClass = "btn-push-disabled";
                        this.Attendance = true;
                        this.AttendanceClass = "btn-push-disabled";
                        break;
                    case '作業中':
                        this.move = true;
                        this.moveClass = "btn-push-disabled";
                        this.work = false;
                        this.workClass = "btn-push";
                        this.outoffice = true;
                        this.outofficeClass = "btn-push-disabled";
                        this.rest = true;
                        this.restClass = "btn-push-disabled";
                        this.Leaving = true;
                        this.LeavingClass = "btn-push-disabled";
                        this.Attendance = true;
                        this.AttendanceClass = "btn-push-disabled";
                        break;
                    case '外出中':
                        this.move = true;
                        this.moveClass = "btn-push-disabled";
                        this.work = true;
                        this.workClass = "btn-push-disabled";
                        this.outoffice = false;
                        this.outofficeClass = "btn-push";
                        this.rest = true;
                        this.restClass = "btn-push-disabled";
                        this.Leaving = true;
                        this.LeavingClass = "btn-push-disabled";
                        this.Attendance = true;
                        this.AttendanceClass = "btn-push-disabled";
                        break;
                    default:
                        this.move = false;
                        this.moveClass = "btn-push";
                        this.work = false;
                        this.workClass = "btn-push";
                        this.outoffice = false;
                        this.outofficeClass = "btn-push";
                        this.rest = false;
                        this.restClass = "btn-push";
                        this.Leaving = false;
                        this.LeavingClass = "btn-push btn-blue";
                        this.Attendance = false;
                        this.AttendanceClass = "btn-push btn-blue";
                        break;
                    }
                
            }

        })

    }
    /* ------------------------
        ポップアップウィンドウ
    ------------------------ */
    TimeStamp(event) {
        this.CommentValue = "";
            if(event.target.dataset.type === "AttendanceChange"){
                this.AttendanceOpen = true;
            }else{
                this.AttendanceOpen = false;
        }
        //シンプルモードならそのまま登録
        if(this.SimpleTimeStampMode){
            this.saveMethod();
        }else{
            this.openmodel = true;
        }
        
    }
    saveMethod() {
        this.loading = true;

        //登録する項目をセット
        const fields = {};
        fields[T_MEMBERID_FIELD.fieldApiName] = this.MemberMasterInfo.Id;//メンバーId
        
        //シンプル登録モードだったら打刻種別のみ更新
        if(this.SimpleTimeStampMode){
            if(this.AttendanceOpen){
                fields[TIMESTAMPTYPE_FIELD.fieldApiName] = "出社打刻";
            }else{
                fields[TIMESTAMPTYPE_FIELD.fieldApiName] = "退社打刻";
            }
        }else{
            fields[T_COMMENT_FIELD.fieldApiName] = this.CommentValue;
            if(this.AttendanceOpen){
                fields[TIMESTAMPTYPE_FIELD.fieldApiName] = "出社打刻";
                fields[T_ATTENDANCE_FIELD.fieldApiName] = this.AttendanceTimeValue;
            }else{
                fields[TIMESTAMPTYPE_FIELD.fieldApiName] = "退社打刻";
                fields[T_LEAVING_FIELD.fieldApiName] = this.LeavingTimeValue;
            }
        }
        const recordInput = { apiName: TIMESTAMP_OBJECT.objectApiName, fields };
        this.CreateTimeStampRecord(recordInput);      
    }

    

    /**
     * 打刻レコード作成：作業状況
     * @param {event}} event 
     * 
    */
    WorkingChange(event){
        this.loading = true;
        console.log("ステータスは？");
        console.log(event.target.dataset.status);
        console.log("this.MemberInfo.WorkingStatus__c："+this.MemberMasterInfo.WorkingStatus__c);
        console.log("event.target.dataset.workingtype："+event.target.dataset.workingtype);
        
        let status;
        //今のステータスと押したボタンがイコールだったら終了処理
        if(!(this.MemberMasterInfo.WorkingStatus__c === undefined || this.MemberMasterInfo.WorkingStatus__c === "" )){
            status = event.target.dataset.workingtype;
            switch( event.target.dataset.workingtype ) {
                case '休憩中':
                    status = "休憩終了";
                    break;
                case '移動中':
                    status = "移動終了";
                    break;
                case '作業中':
                    status = "作業終了";
                    break;
                case '外出中':
                    status = "戻り";
                    break;
            }
        }else{
            switch( event.target.dataset.workingtype ) {
                case '休憩中':
                    status = "休憩開始";
                    break;
                case '移動中':
                    status = "移動開始";
                    break;
                case '作業中':
                    status = "作業開始";
                    break;
                case '外出中':
                    status = "外出";
                    break;
            }
        }
        const fields = {};
        fields[T_MEMBERID_FIELD.fieldApiName] = this.MemberMasterInfo.Id;//メンバーId
        fields[TIMESTAMPTYPE_FIELD.fieldApiName] = status;//WorkingStatus__c

        const recordInput = { apiName: TIMESTAMP_OBJECT.objectApiName, fields };
        this.CreateTimeStampRecord(recordInput);      
    }
    /* END:WorkingChange */
    
    /*
        タイムスタンプレコード作成
    */
    CreateTimeStampRecord(recordInput){
        createRecord(recordInput)
            .then(() => {
                this.GetMasterMember();
                let SendData = {
                        Mode : "reload",
                        MemberMasterInfo : this.MemberMasterInfo,
                        SelectDate : Today,
                        SelectDateProcess : TodayProcess,
                        SelectDateText : TodayText,
                    }
                /* 他のComponnentに更新情報を送信 */
                fireEvent(this.pageRef, 'UpsertTimeStamp',SendData);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '成功',
                        message: '打刻レコードを作成しました。',
                        variant: 'success',
                    }),
                );
                
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '打刻レコード作成エラー',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.loading = false;
            });
    }
    /* END:CreateTimeStampRecord */




}
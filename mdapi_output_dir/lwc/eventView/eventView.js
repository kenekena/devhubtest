/* eslint-disable no-console */

import { LightningElement,track,wire } from 'lwc';

/* 共通jsの読み込み */
import { ChangeText,ChangeProcess } from 'c/commonJs';

import GetUserId from '@salesforce/user/Id';

import findEvent from '@salesforce/apex/Lwc_Find_Attendance_Controller.findEvent';

/* PubSub */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

const Today = new Date();
const TodayText = ChangeText(Today);
const TodayProcess = ChangeProcess(Today);


export default class EventView extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track SelectDate = Today;
    @track SelectDateProcess = TodayProcess;
    @track SelectDateText = TodayText;
    @track SelectUserId = GetUserId;
    @track Title = this.SelectDateText + "の行動";
    @track EventlList =[];

    columns = [
        { label: '行動種別', fieldName: 'Type' },
        { label: '予定開始', fieldName: 'StartTime__c'},
        { label: '予定終了', fieldName: 'EndTime__c'},
        { label: '件名', fieldName: 'Subject'}
    ];

    connectedCallback() {
        this.GetEvent();
        /* 他のComponentに更新情報を受信 */
        registerListener('ChangeDaily', this.RedrawEvent, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    RedrawEvent(SendData) {
        console.log("■■■eventView■■■：SendData");
        console.log(SendData);
        
        if( !(SendData.SelectUserId === "") || !(SendData.SelectUserId === undefined)){
            this.SelectDate = SendData.SelectDate;
            this.SelectDateProcess = SendData.SelectDateProcess;
            this.SelectDateText = SendData.SelectDateText;
            this.SelectUserId = SendData.SelectUserId;
            this.GetEvent();
        }else{
            this.EventlList = [];
        }
    }

    GetEvent(){
        findEvent({
            SelectDateProcess : this.SelectDateProcess,
            UserID : this.SelectUserId
        })
            .then(result => {
                this.EventlList = [];
                for(let i = 0; i< result.length; i++){
                    if(result[i].IsAllDayEvent){
                        result[i].Type = "（終日）" + result[i].Type;
                    }
                }
                
                this.EventlList = result;
                
            })
    }



}
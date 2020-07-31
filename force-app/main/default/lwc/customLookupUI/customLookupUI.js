import { LightningElement ,api } from 'lwc';
import fetchSearchedData from '@salesforce/apex/CustomLookupHelper.fetchSearchedData';
export default class CustomLookupUI extends LightningElement {
    @api objectDescription;
    @api queryFields;
    @api searchFields;
    @api labelRequired;
    @api sobjectType;
    @api selectedId = null;
    selectedRec = null;
    timeOut;
    DELAY_TIME =1000;
    fieldLabel = 'Name not found!';
    placeholder = 'Plural not found!';
    recordsFetched = [];
    get isSelected(){
        return this.selectedRec!==null;
    }
    get recordExist(){
        return this.recordsFetched.length>0;
    } 
    connectedCallback(){
        
        if(this.objectDescription['fieldLabel']){
            this.fieldLabel = this.objectDescription['fieldLabel']; 
        }
        if(this.objectDescription['sobjectNamePlural']){
            this.placeholder = `Search ${this.objectDescription['sobjectNamePlural']}...`; 
        }  
        if(this.selectedId){
            
            fetchSearchedData({queryFields : this.queryFields,searchFields : this.searchFields,sobjectType: this.objectDescription['sobjectAPI'],searchKey :null,selectedId : this.selectedId})
            .then(result => {
                if(result){
                    this.selectedId = result[0].fieldId;
                    this.selectedRec = result[0];  
                    if(this.selectedRec){
                        this.template.querySelector('.comboBoxContainer').classList.add('slds-has-selection');
                    }  
                }
                else{
                    this.selectedId = null;
                    this.selectedRec = null;
                }
                
            })
            .catch(err => {
                console.log(err);
            });
        }
        
    }
    renderedCallback(){
        if(!this.labelRequired){
            this.template.querySelector('.slds-form-element__label').style.display='none';
        }
        
    }
    handleSelectedRec(event){
        const index = event.currentTarget.dataset.index;
        this.selectedId = this.recordsFetched[index]['fieldId'];
        this.selectedRec = this.recordsFetched[index];
        this.recordsFetched = [];
        this.template.querySelector('.comboBoxContainer').classList.add('slds-has-selection');
        this.dispatchEvent(new CustomEvent('selectedid',{bubbles : true,composed : true,detail : {selectedId : this.selectedId}}));
    }
    handleRemoveSelection(){
        this.template.querySelector('.comboBoxContainer').classList.remove('slds-has-selection');
        this.selectedId =null;
        this.selectedRec =null;
    }

    handleSearchKey(){
        if(this.timeOut)
            clearTimeout(this.timeOut);
        this.timeOut = setTimeout(()=>{
            const searchKey = this.template.querySelector('.inputText').value;
            if(searchKey&&searchKey.length>2){
                fetchSearchedData({queryFields : this.queryFields,searchFields : this.searchFields,sobjectType: this.objectDescription['sobjectAPI'],searchKey :searchKey,selectedId : null})
                .then(result => {
                    this.recordsFetched = result;
                })
                .catch(err => {
                    console.log(err);
                });
            }
            else{
                this.recordsFetched = [];
            }
            
        },this.DELAY_TIME);
    }
}
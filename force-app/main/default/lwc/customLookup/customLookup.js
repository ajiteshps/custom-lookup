import { LightningElement, api } from 'lwc';
import checkObjectAndFields from '@salesforce/apex/CustomLookupHelper.checkObjectAndFields';
export default class CustomLookup extends LightningElement {
    @api sobjectType = '';
    @api fieldName = '';
    @api labelRequired = '';
    @api createWindow = 'true';
    @api queryFields = 'Name,CreatedDate,LastModifiedDate';
    @api searchFields = 'Name';
    @api selectedId=null;
    objectDescriptionFetched = null;
    errorMsg = '';
    appState = 'initial';
    isLoading  = false;
    get errorState(){
        return this.appState ==='error';
    }
    get appWorkingState(){
        return this.appState ==='working';
    }
    connectedCallback(){
        if(!this.sobjectType||!this.fieldName){
            this.errorMsg = 'SobjectType or FieldName is missing. Please input the values and try again';
            this.appState ='error';
        }
        else{
            this.isLoading = true;
            checkObjectAndFields({sobjectType : this.sobjectType,fieldName : this.fieldName})
                .then(result=> {
                    if(result['error']){
                        this.appState ='error';
                        this.errorMsg = result['error'];
                    }
                    else{
                        this.appState = 'working';
                        this.objectDescriptionFetched = result;
                    }
                    this.isLoading = false;
                })
                .catch(err => {
                    console.log(err);
                    this.isLoading = false;
                })
        }
    }
    
}
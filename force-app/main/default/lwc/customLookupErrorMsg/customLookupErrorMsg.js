import { LightningElement, api } from 'lwc';

export default class CustomLookupErrorMsg extends LightningElement {
    @api errorMsg = 'Something went wrong. Please reach out to the developer !'
}
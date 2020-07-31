# custom-lookup
Custom Lookup that can be configured for any object and field . It can be used anywhere in lightning component where one cannot use lightning input forms due to certain limitations . Compatible with LWC , Aura Component and Visualforce (with Lightning out)


# Usage
Aura
<c:customLookup sobjectType='Sector__c' labelRequired='true'  onselectedid="{!c.myAction}" fieldName='Account__c' />
LWC
<c-custom-lookup sobject-type='Sector__c' label-required='true'  onselectedid={handleMyAction} field-name='Account__c' />

# Attributes for configuration

sobjectType : The API name of Sobject on which the lookup field exists
labelRequired : Pass any value to allow the label to be visible
onselectedid : Will return Id of selected record with "selectedId" key
fieldName : API name of the field for which custom Lookup need to be created

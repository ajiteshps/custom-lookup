public with sharing class CustomLookupHelper {
    Schema.SOAPType soapType;
    @AuraEnabled
    public static Map<String,String> checkObjectAndFields(String sobjectType,String fieldName){
        Map<String,String> errorMsg = new Map<String,String>();
        if(!checkForSObjectType(sobjectType)){
            errorMsg.put('error','Sobject does not exist or the user dosent have rights for the same!');
            return errorMsg;
        }
        Schema.SObjectField fieldDescription = checkForFieldType(sobjectType,fieldName);
        if(fieldDescription==null){
            errorMsg.put('error','Sobject does not exist or the user dosent have rights for the same!');
            return errorMsg;
        }
        if(!checkLookupType(fieldDescription)){
            errorMsg.put('error','Field specified is not of type lookup!');
            return errorMsg;
        }
        errorMsg = objectTypePropertiesFetch(fieldDescription);
        
        return errorMsg;
    }
    public static Map<String,String> objectTypePropertiesFetch(Schema.SObjectField lookupFieldDescription){
        Map<String,String> lookupPropertyMap = new Map<String,String>();
        Schema.DescribeSObjectResult lookupObjectDescription = lookupFieldDescription.getDescribe().getReferenceTo()[0].getDescribe();
        lookupPropertyMap.put('sobjectAPI',String.valueOf(lookupFieldDescription.getDescribe().getReferenceTo()[0]));
        lookupPropertyMap.put('sobjectName',lookupObjectDescription.getName());
        lookupPropertyMap.put('sobjectNamePlural',lookupObjectDescription.getLabelPlural());
        lookupPropertyMap.put('isCreateable',''+lookupObjectDescription.isCreateable());
        lookupPropertyMap.put('fieldLabel',''+lookupFieldDescription.getDescribe().getLabel());
        return lookupPropertyMap;
    }
    public static Boolean checkLookupType(Schema.SObjectField fieldDescription){
        Schema.DescribeFieldResult fieldLevelDescription = fieldDescription.getDescribe();
        if(fieldLevelDescription.getSOAPType()==soapType.ID){
            return true;
        }
        return false;
    }
    public static Schema.SObjectField checkForFieldType(String sobjectType,String fieldName){
        if(!Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap().containsKey(fieldName)){
            return null;
        }
        Schema.SObjectField fieldDescription = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap().get(fieldName);
        return fieldDescription;
    }
    public static Boolean checkForSObjectType(String sobjectType){
        SObjectType objToken = Schema.getGlobalDescribe().get(sobjectType);
        if(objToken  != null)
            return true;
        return false;
    }
    @AuraEnabled
    public static List<LookupWrapper> fetchSearchedData(String queryFields,String searchFields,String sobjectType,String searchKey,String selectedId){
        Map<String,String> queryFieldDataType = queryDataTypeFields(queryFields,sobjectType);
        Set<String> searchFieldSelected = searchDataTypeFields(searchFields,sobjectType);
        String queryFieldString = '';
        String searchFieldString ='';
        for(String tempString : queryFieldDataType.keySet()){
            queryFieldString+=tempString+',';
        }
        queryFieldString = queryFieldString.subString(0,queryFieldString.length()-1);
        if(selectedId!=null){
            searchFieldString  += 'Id = \''+selectedId+'\' ';
        }
        else{
            for(String tempString : searchFieldSelected){
                searchFieldString  += tempString+' LIKE \''+searchKey+'%\' OR ';
            }
            searchFieldString = searchFieldString.subString(0,searchFieldString.length()-3);
        }
        
        
        String finalQuery = 'SELECT '+queryFieldString+' FROM '+sobjectType+' WHERE '+searchFieldString+' LIMIT 5';
        List<sObject> sObjectList = Database.query(finalQuery);
        List<LookupWrapper> dataWrapper = new List<LookupWrapper>();
        for(sObject sObjectRec : sObjectList){
            Integer i = 0;
            LookupWrapper tempWrapper = new LookupWrapper();
            for(String fieldAPI : queryFieldDataType.keySet()){
                String value;
                if(queryFieldDataType.get(fieldAPI)=='STRING'){
                    value = (String)sObjectRec.get(fieldAPI);
                }
                else if(queryFieldDataType.get(fieldAPI)=='DATETIME'){
                    value = formatDateTime((DateTime)sObjectRec.get(fieldAPI));
                }
                else if(queryFieldDataType.get(fieldAPI)=='DATE'){
                    value = formatDate((Date)sObjectRec.get(fieldAPI));
                }
                else if(queryFieldDataType.get(fieldAPI)=='BOOLEAN'){
                    value = booleanStrConversion((Boolean)sObjectRec.get(fieldAPI));
                }
                
                if(i==0){
                    tempWrapper.fieldOne = value;
                }
                else if(i==1){
                    tempWrapper.fieldTwo = value;
                }
                else if(i==2){
                    tempWrapper.fieldThree = value;
                }
                
                i++;
            }
            tempWrapper.fieldId = (String)sObjectRec.get('Id');
            if(tempWrapper.fieldTwo!=null&&tempWrapper.fieldThree!=null){
                tempWrapper.fieldFour = tempWrapper.fieldTwo+' . '+tempWrapper.fieldThree;
            }
            dataWrapper.add(tempWrapper);
        }
        return dataWrapper;
        
    }
    public static String formatDate(Date dateRecord){
        String dateStr = '';
        if(dateRecord!=null){
	        Integer day = dateRecord.day();
            Integer year = dateRecord.year();
            Integer month = dateRecord.month();
            DateTime dateTimeRecord = DateTime.newInstance(year,month,day);
			dateStr = day+' '+dateTimeRecord.format('MMM')+' '+year;            
        }
	    return dateStr;
    }
    public static String formatDateTime(DateTime dateTimeRecord){
        String dateStr = '';
        if(dateTimeRecord!=null){
	        Integer day = dateTimeRecord.day();
            Integer year = dateTimeRecord.year();
            Integer month = dateTimeRecord.month();
	        dateStr = day+' '+dateTimeRecord.format('MMM')+' '+year;            
        }

        return dateStr;
    }
    public static String booleanStrConversion(Boolean boolValue){
        if(boolValue!=null){
            return String.valueOf(boolValue);
        }
        return String.valueOf('');
    }
    public static Map<String,String> queryDataTypeFields(String queryFields,String sobjectType){
        List<String> queryFieldArr = queryFields.split(',');
        Map<String,String> queryFieldDataType = new Map<String,String>();
        Map<String,Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap();
        for(integer i =0;i<=2;i++ ){
            if((queryFieldArr.size())>i&&objectFields.containsKey(queryFieldArr[i])){
                Schema.SObjectField tempObjectField = objectFields.get(queryFieldArr[i]);
                queryFieldDataType.put(queryFieldArr[i],tempObjectField.getDescribe().getSOAPType().name());
            }
            else if(i==0){
                queryFieldDataType.put('Name',Schema.SOAPType.String.name());
            }
            else if(i==1){
                queryFieldDataType.put('CreatedDate',Schema.SOAPType.DateTime.name());
            }
            else if(i==2){
                queryFieldDataType.put('LastModifiedDate',Schema.SOAPType.DateTime.name());
            }
        }
        
        return queryFieldDataType;
    }
    public static Set<String> searchDataTypeFields(String searchFields,String sobjectType){
        List<String> searchFieldArr = searchFields.split(',');
        Set<String> selectedFields = new Set<String>();
        Map<String,Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sobjectType).getDescribe().fields.getMap();
        for(integer i =0;i<searchFieldArr.size();i++ ){
            if((searchFieldArr.size())>i&&objectFields.containsKey(searchFieldArr[i])){
                Schema.SObjectField tempObjectField = objectFields.get(searchFieldArr[i]);
                if(tempObjectField.getDescribe().getSOAPType().name()=='STRING'){
                    selectedFields.add(searchFieldArr[i]);
                }
            }
        }
        if(selectedFields.size()==0){
            selectedFields.add('Name');
        }
        
        return selectedFields;
    }

    class LookupWrapper{
        @AuraEnabled public String fieldOne;
        @AuraEnabled public String fieldTwo;
        @AuraEnabled public String fieldThree;
        @AuraEnabled public String fieldFour;
        @AuraEnabled public String fieldId;
    }
}
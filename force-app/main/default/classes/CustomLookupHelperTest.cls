@isTest
private class CustomLookupHelperTest {
    @isTest static void objectAndFieldTest(){
        CustomLookupHelper.checkObjectAndFields('Contact','AccountId');
        CustomLookupHelper.checkObjectAndFields('Wrong Object','AccountId');
        CustomLookupHelper.checkObjectAndFields('Contact','Wrong Field');
        CustomLookupHelper.checkObjectAndFields('Contact','Birthdate');
    }
    @isTest static void dataFetchTest(){
        CustomLookupHelper.fetchSearchedData('Name,Id','Name','Contact','Aji',null);

    }
    @isTest static void dataFetchPostInsertionTest(){
        Date birthdate = Date.newInstance(1994, 12, 05);
        Contact con = new Contact(FirstName='Aji',Salutation='Mr.',LastName='Aji',Birthdate=birthdate);
        insert con; 
        CustomLookupHelper.fetchSearchedData('Name','Name','Contact','Aji',null);
        CustomLookupHelper.fetchSearchedData('Name,Birthdate','Name','Contact','Aji',null);	

    }
}
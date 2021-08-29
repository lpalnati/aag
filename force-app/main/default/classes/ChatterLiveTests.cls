@isTest
private class ChatterLiveTests{

    static testMethod void testFeedUpdateObject(){
        FeedUpdateObject f = new FeedUpdateObject ('ryan', '1', 'guest', '2', 'hi');
        String expected = 'feed = { "fromName": "ryan", "fromId": "/_ui/core/userprofile/UserProfilePage?u=1" , "toName" : "guest", "toId" : "/_ui/core/userprofile/UserProfilePage?u=2", "message" : "hi" }';
        System.assert(expected  == f.getJSON());
        System.assert(f.getIsFeedPost());
        System.assert(!f.getIsStatusUpdate());
        
    }
    
    static testMethod void testGroupUpdateObject(){
        GroupUpdateObject g = new GroupUpdateObject('ryan', '1', 'public school', '209', 'hi everybody');
        String expected = 'feed= { "fromName": "ryan", "fromId": "/_ui/core/userprofile/UserProfilePage?u=1" , "toName" : "public school", "toId" : "/_ui/core/chatter/groups/GroupProfilePage?g=209", "message" : "hi everybody" }';
        System.assert(expected  == g.getJSON());
        System.assert('/_ui/core/chatter/groups/GroupProfilePage?g=209' == g.getToLink());
        System.assert('/_ui/core/userprofile/UserProfilePage?u=1' == g.getFromLink());
    
    }
    static testMethod void testGroupUpdates() {
        String groupName = 'a' + System.currentTimeMillis();
        insert new CollaborationGroup(name=groupName , CollaborationType ='Public');
        CollaborationGroup g = [select id from CollaboratioNGroup where name=:groupName];
        insert new FeedPost(Type='TextPost', Parentid= g.id, body='hi');
        
        ChatterLiveController c = new ChatterLiveController();
        List<GroupUpdateObject> s = c.getGroupUpdates();
        System.assert('hi' == s[0].message);
        System.assert('skip' == c.getLastGroupUpdate());
    }
    
    static testMethod void testGetUserUpdates(){
        String testStatus = 'this is a test';
        User u = [select id from User where isactive= true LIMIT 1];
        u.CurrentStatus = testStatus;
        update u;
        
        ChatterLiveController c = new ChatterLiveController();
        List<FeedUpdateObject> s = c.getFeedUpdates();
        System.assert(testStatus  == s[0].message);
        System.assert(c.getFeedUpdates()  == null);
        System.assert(c.getLastUserUpdate()  == 'skip');
        u.CurrentStatus = testStatus + '2';
        update u;
        System.debug(c.getLastUserUpdate() + 'yyyyyyyyyyyyyy');
        //insert new FeedPost(Type='LinkPost', linkurl='http://www.salesforce.com', Parentid= u.id); 
        //insert new FeedPost(Type='ContentPost', ContentFileName = 'http://www.salesforce.com', ContentData = Blob.valueOf('test'), Parentid= u.id);
    }
}
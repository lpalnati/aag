public with sharing class ChatterLiveController {
    Datetime lastUserUpdate;
    Datetime lastGroupUpdate;
    boolean initializeUserPosts = false;
    boolean initializeGroupPosts = false;
    
    public String getLastGroupUpdate() {
        if(lastGroupUpdate == null){
            return 'skip';
        }
        
        String soqlDateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        String LongDate = lastGroupUpdate.format(soqlDateFormat, 'GMT');
                
        CollaborationGroupFeed [] feeds;
        try{
            
            feeds = Database.query('select ID, Type, FeedPost.Body, CreatedById, ParentId, CreatedBy.Name, Parent.Name, CreatedDate FROM CollaborationGroupFeed WHERE Type in (\'TextPost\') AND CreatedDate > ' + longDate + ' ORDER by CreatedDate DESC LIMIT 200');
        }
        catch(System.QueryException e){
            return 'skip';
        }
        if(feeds.size() == 0){
            return 'skip';
        }

        CollaborationGroupFeed feed = feeds[feeds.size() - 1];
        lastGroupUpdate = feed.CreatedDate;

        return new GroupUpdateObject(feed.CreatedBy.Name, feed.CreatedById, feed.Parent.Name, feed.ParentId, feed.FeedPost.Body).getJSON();
    }

    public String getLastUserUpdate() {
        if(lastUserUpdate == null){
            return 'skip';
        }
        
        String soqlDateFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        String LongDate = lastUserUpdate.format(soqlDateFormat, 'GMT');
               
        UserFeed[] feeds;
        try{
           
            feeds = Database.query('select ID, Type, FeedPost.Body, CreatedById, ParentId, CreatedBy.Name, Parent.Name, CreatedDate FROM UserFeed WHERE Type in (\'UserStatus\', \'TextPost\') AND CreatedDate > ' + longDate + ' ORDER by CreatedDate DESC LIMIT 200');
        }
        catch(System.QueryException e){
            return 'skip';
        }
        if(feeds.size() == 0){
            return 'skip';
        }

        UserFeed feed = feeds[feeds.size() - 1];
        lastUserUpdate = feed.CreatedDate;

        return new FeedUpdateObject(feed.CreatedBy.Name, feed.CreatedById, feed.Parent.Name, feed.ParentId, feed.FeedPost.Body).getJSON();
    }
    

    public List<FeedUpdateObject> getFeedUpdates(){
        if(initializeUserPosts){
            return null;
        }

        List<FeedUpdateObject> updates = new List<FeedUpdateObject>();
        UserFeed[] feeds;
        try {
            feeds = [select ID, Type, FeedPost.Body, CreatedById, ParentId, CreatedBy.Name, Parent.Name, CreatedDate FROM UserFeed WHERE Type in ('UserStatus', 'TextPost') ORDER by CreatedDate DESC LIMIT 10];
        }
        catch(System.QueryException e){
            return updates;
        }
        for(UserFeed feed: feeds){
            updates.add(new FeedUpdateObject(feed.CreatedBy.Name, feed.CreatedById, feed.Parent.Name, feed.ParentId, feed.FeedPost.Body));
        }
        lastUserUpdate = DateTime.now();
        
        initializeUserPosts = true;
        return updates;
    }
    
    public List<GroupUpdateObject> getGroupUpdates(){
        if(initializeGroupPosts){
            return null;
        }

        List<GroupUpdateObject> updates = new List<GroupUpdateObject>();
        CollaborationGroupFeed[] feeds;
        try {
            feeds = [select ID, Type, FeedPost.Body, CreatedById, ParentId, CreatedBy.Name, Parent.Name, CreatedDate FROM CollaborationGroupFeed WHERE Type in ('TextPost') ORDER by CreatedDate DESC LIMIT 10];
        }
        catch(System.QueryException e){
            return updates;
        }
        for(CollaborationGroupFeed feed: feeds){
            updates.add(new GroupUpdateObject(feed.CreatedBy.Name, feed.CreatedById, feed.Parent.Name, feed.ParentId, feed.FeedPost.Body));
        }
        lastGroupUpdate = DateTime.now();
        
        initializeGroupPosts = true;
        return updates;
    }
}
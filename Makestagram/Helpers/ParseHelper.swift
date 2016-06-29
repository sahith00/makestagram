//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Sahith Bhamidipati on 6/24/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    // Following Relation
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    
    // Like Relation
    static let ParseLikeClass         = "Like"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "user"
    static let ParsePostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
                
        query.skip = range.startIndex
        query.limit = range.endIndex - range.startIndex
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func likePost(user: PFUser, post: Post){
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
    }
    
    static func unlikePost(user: PFUser, post: Post){
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
                }
            }
        }
    }
    
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        query.includeKey(ParseLikeFromUser)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // MARK: Following
    
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
    }
    
    static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            
            let results = results ?? []
            
            for follow in results {
                follow.deleteInBackgroundWithBlock(ErrorHandling.errorHandlingCallback)
            }
        }
    }
    
    // MARK: Users
    
    
    static func allUsers(completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!
        // exclude the current user
        query.whereKey(ParseHelper.ParseUserUsername,
                       notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
    
    static func searchUsers(searchText: String, completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername,
                                             matchesRegex: searchText, modifiers: "i")
        
        query.whereKey(ParseHelper.ParseUserUsername,
                       notEqualTo: PFUser.currentUser()!.username!)
        
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
}

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
}
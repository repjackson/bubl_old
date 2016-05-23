Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            profile: 1
            username: 1

Meteor.publish 'usernames', ->
    Meteor.users.find {},
        fields:
            username: 1

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            profile: 1
            username: 1

Meteor.publish 'sent_messages', ->
    Messages.find
        authorId: @userId


Meteor.publish 'received_messages', ->
    Messages.find
        recipientId: @userId



Meteor.publish 'people', (selectedtags)->
    self = @
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    Meteor.users.find match,
        fields:
            tags: 1
            profile: 1
            username: 1


Meteor.publish 'people_tags', (selectedtags)->
    self = @
    match = {}
    if selectedtags?.length > 0 then match.tags = $all: selectedtags
    match._id = $ne: @userId

    tagCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    tagCloud.forEach (tag, i) ->
        self.added 'people_tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()


Meteor.publish 'tags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()


Meteor.publish 'doc', (id)-> Docs.find id


Meteor.publish 'docs', (selectedtags)->
    match = {}
    match.tagCount = $gt: 0
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    Docs.find match,
        limit: 5
        sort:
            tagCount: 1
            timestamp: -1

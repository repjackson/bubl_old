Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docs', selected_tags.array()

Template.docs.helpers
    docs: -> Docs.find {},
        # limit: 5
        sort:
            tagCount: 1
            timestamp: -1
    # docs: -> Docs.find()


Template.view.onCreated ->
    # console.log @data.authorId
    Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()

    when: -> moment(@timestamp).fromNow()

    user: -> Meteor.user()

    doc_tag_class: ->
        result = ''
        if @valueOf() in selected_tags.array() then result += ' primary' else result += ' basic'
        return result

    select_user_button_class: -> if Session.equals 'selected_user', @authorId then 'primary' else 'basic'

    cloud_label_class: -> if @name in selected_tags.array() then 'primary' else 'basic'



Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .authorFilterButton': ->
        if @username in selectedUsernames.array() then selectedUsernames.remove @username else selectedUsernames.push @username

    'click .cloneDoc': ->
        # if confirm 'Clone?'
        id = Docs.insert
            tags: @tags
            body: @body
        FlowRouter.go "/edit/#{id}"


    'click .select_user': ->
        if Session.equals('selected_user', @authorId) then Session.set('selected_user', null) else Session.set('selected_user', @authorId)


Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('docId')


Template.edit.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId


Template.edit.events
    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', FlowRouter.getParam('docId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/'
        	).modal 'show'


    'keydown #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('docId'),
                        $addToSet: tags: tag
                    $('#addTag').val('')
                else
                    Docs.update FlowRouter.getParam('docId'),
                        $set:
                            tagCount: @tags.length
                    selected_tags.clear()
                    for tag in @tags
                        selected_tags.push tag
                    FlowRouter.go '/'

    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: tag
        $('#addTag').val(tag)



    'click #saveDoc': ->
        Docs.update FlowRouter.getParam('docId'),
            $set:
                tagCount: @tags.length
        # selected_tags.clear()
        # for tag in @tags
        #     selected_tags.push tag
        FlowRouter.go '/'


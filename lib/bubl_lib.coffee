@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'


Docs.before.insert (userId, doc)->
    doc.app = 'bubl'
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    return



Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tagCount = doc.tags.length
    # Meteor.call 'generatePersonalCloud', Meteor.userId()
), fetchPrevious: true




Docs.helpers
    author: -> Meteor.users.findOne @authorId
    when: -> moment(@timestamp).fromNow()



Meteor.methods
    createDoc: (tags=[])->
        Docs.insert
            tags: tags
            tagCount: tags.length

    delete_doc: (id)->
        Docs.remove id


    removetag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag

    addtag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username


AccountsTemplates.configure
    defaultLayout: 'layout'
    defaultLayoutRegions:
        nav: 'nav'
    defaultContentRegion: 'main'
    showForgotPasswordLink: true
    overrideLoginErrors: true
    enablePasswordChange: true

    # sendVerificationEmail: true
    # enforceEmailVerification: true
    #confirmPassword: true
    #continuousValidation: false
    #displayFormLabels: true
    #forbidClientAccountCreation: true
    #formValidationFeedback: true
    #homeRoutePath: '/'
    #showAddRemoveServices: false
    #showPlaceholders: true

    negativeValidation: true
    positiveValidation: true
    negativeFeedback: false
    positiveFeedback: true

    # Privacy Policy and Terms of Use
    #privacyUrl: 'privacy'
    #termsUrl: 'terms-of-use'

pwd = AccountsTemplates.removeField('password')
AccountsTemplates.removeField 'email'
AccountsTemplates.addFields [
    {
        _id: 'username'
        type: 'text'
        displayName: 'username'
        required: true
        minLength: 3
    }
    # {
    #     _id: 'email'
    #     type: 'email'
    #     required: false
    #     displayName: 'email'
    #     re: /.+@(.+){2,}\.(.+){2,}/
    #     errStr: 'Invalid email'
    # }
    # {
    #     _id: 'username_and_email'
    #     type: 'text'
    #     required: false
    #     displayName: 'Login'
    # }
    pwd
]

AccountsTemplates.configureRoute 'changePwd'
AccountsTemplates.configureRoute 'forgotPwd'
AccountsTemplates.configureRoute 'resetPwd'
AccountsTemplates.configureRoute 'signIn'
AccountsTemplates.configureRoute 'signUp'
AccountsTemplates.configureRoute 'verifyEmail'


FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'cloud'
        main: 'docs'

FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'


FlowRouter.route '/edit/:docId', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'

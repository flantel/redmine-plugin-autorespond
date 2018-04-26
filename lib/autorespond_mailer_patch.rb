require_dependency 'mailer'

module AutorespondMailerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
    def custom_mail(issue, from, content)
        redmine_headers 'Project' => issue.project.identifier,
            'Issue-Id' => issue.id,
            'Issue-Author' => issue.author.login
        redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
	redmine_headers 'Project-Specific-Sender' => issue.project.email if issue.project.email
        message_id issue
        references issue
        @content = content
        @issue = issue
        @author = issue.author
        @users =  [issue.author]
        @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)

        mail :to => from,
            :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
    end

  end

end

Mailer.send(:include, AutorespondMailerPatch)

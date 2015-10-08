#!/usr/bin/env ruby

#
# Tag deletion protection monkey-patch.
#

begin
  require File.expand_path('../../../app/services/delete_tag_service.rb', __FILE__)
rescue LoadError
  Rails.logger.error("#{DateTime.now} initializers/#{File.basename(__FILE__)}: #{$!.message}")
end

#
# Apply tag protection to the tag deletion service.
#

class DeleteTagService < BaseService
  def execute_with_protected_tags(tag_name)
    domain = "#{project.namespace.name}/#{project.name}"
    config = File.join(File.dirname(__FILE__), "#{File.basename(__FILE__, '.rb')}.conf")
    config = File.exist?(config) ? eval(File.read(config)) : {}
    match = config.fetch(:domains, { // => [ // ] }).any? { |d, ts| d =~ domain && Array(ts).any? { |t| t =~ tag_name } }

    if match
      if config[:admin] && current_user.is_admin?
        Rails.logger.info("#{DateTime.now} initializers/#{File.basename(__FILE__)}: ALLOW DELETE_TAG #{domain} => #{tag_name}")
        execute_without_protected_tags(tag_name)
      else
        team = project.team
        membership = team.find_member(current_user)
        if membership
          if config[:owner] && membership.owner?
            Rails.logger.info("#{DateTime.now} initializers/#{File.basename(__FILE__)}: ALLOW DELETE_TAG #{domain} => #{tag_name}")
            execute_without_protected_tags(tag_name)
          elsif config[:master] && (team.master?(current_user) || membership.owner?)
            Rails.logger.info("#{DateTime.now} initializers/#{File.basename(__FILE__)}: ALLOW DELETE_TAG #{domain} => #{tag_name}")
            execute_without_protected_tags(tag_name)
          elsif config[:developer] && (team.developer?(current_user) || team.master?(current_user) || membership.owner?)
            Rails.logger.info("#{DateTime.now} initializers/#{File.basename(__FILE__)}: ALLOW DELETE_TAG #{domain} => #{tag_name}")
            execute_without_protected_tags(tag_name)
          else
            Rails.logger.warn("#{DateTime.now} initializers/#{File.basename(__FILE__)}: DENY DELETE_TAG #{domain} => #{tag_name}")
            error("You're not allowed to delete tags.")
          end
        else
          Rails.logger.warn("#{DateTime.now} initializers/#{File.basename(__FILE__)}: DENY DELETE_TAG #{domain} => #{tag_name}")
          error("You're not allowed to delete tags.")
        end
      end
    else
      Rails.logger.warn("#{DateTime.now} initializers/#{File.basename(__FILE__)}: ALLOW DELETE_TAG #{domain} => #{tag_name}")
      execute_without_protected_tags(tag_name)
    end
  end
  alias_method_chain :execute, :protected_tags
end

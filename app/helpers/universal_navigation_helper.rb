module UniversalNavigationHelper
  def secondary_tabs_list
    array = [
      {
        :id => :places,
        :title => "Places",
        :app => :places,
        :url_method => :kmaps_url,
        :count_method => :feature_count,
        :shanticon => 'places'
      }]
    array <<
      {
        :id => :topics,
        :title => SubjectsIntegration::Feature.human_name(:count => :many).titleize.s,
        :app => :topics,
        :url_method => :topical_map_url,
        :count_method => :category_count,
        :shanticon => 'subjects'
        #:count_method_args => {:cumulative => true}
      } if defined?(SubjectsIntegration)
    array = array + [
      {
        :id => :pictures,
        :title => "Pictures",
        :app => :media,
        :url_method => :pictures_url,
        :count_method => :media_count,
        :count_method_args => {:type => 'Picture'},
        :shanticon => 'photos'
      },
      {
        :id => :videos,
        :title => "Videos",
        :app => :media,
        :url_method => :videos_url,
        :count_method => :media_count,
        :count_method_args => {:type => 'Video'},
        :shanticon => 'video'
      },
      {
        :id => :documents,
        :title => "Texts",
        :app => :media,
        :url_method => :documents_url,
        :count_method => :media_count,
        :count_method_args => {:type => 'Document'},
        :shanticon => 'sources'
      }
    ]
  end
  
  def active_secondary_tabs_list(current_app_id, current_tab_id, custom_secondary_tabs)
    @tab_options ||= {}
    if current_app_id == :dictionary or current_app_id== :himalayan_search
      tabs = custom_secondary_tabs || []
    else
       tabs = [[:home, "Home", "#{ActionController::Base.config.relative_url_root}/", 'grid']] + custom_secondary_tabs
    end
    unless @tab_options[:entity].blank?
      entity = @tab_options[:entity]
      secondary_tabs_list.each{|tab|
        # Only show tabs from other apps (so that Topics doesn't show up in Topical Map, for example)
        unless current_app_id == tab[:app]
          url = entity.send(tab[:url_method])
          if tab[:count_method].blank?
            tabs << [tab[:id], tab[:title], url]
          else
            if tab[:count_method_args].blank?
              count = entity.send(tab[:count_method])
            else
              count = entity.send(tab[:count_method], tab[:count_method_args])
            end
            tabs << [tab[:id], "#{tab[:title]} (#{count})", url, tab[:shanticon]] if count > 0
          end
        end
      }
    end
    tabs
  end
  
  #
  # The custom_secondary_tabs argument should be an array like [[:place, "Place", feature_url(f.fid)],
  # [:related, "Related", related_features_url(f)]]
  #
  def secondary_tabs_list_items(current_app_id, current_tab_id, custom_secondary_tabs)
    active_secondary_tabs_list(current_app_id, current_tab_id, custom_secondary_tabs).collect do |tab|
      tab_id = tab[0]
      title = tab[1]
      shanticon = tab[3]
      # url = tab[2] USE THIS FOR JS
      if current_tab_id == tab_id
        "<li class=\"#{tab_id}\ active\">
          <a href=\"\##{tab_id}\" data-toggle=\"pill\"><i class=\"icon shanticon-#{shanticon}\"></i>#{title}</a>
        </li>"
      else
        "<li class=\"#{tab_id}\">
          <a href='\##{tab_id}' data-toggle=\"pill\"><i class=\"icon shanticon-#{shanticon}\"></i>#{title}</a>
        </li>"
      end
    end.join("\n").html_safe
  end

  #
  # Returns the HTML for creating the tabs.  Currently only accepts a block instead of a string
  #
  def universal_navigation(*args)
    "<aside class=\"content-resources col-xs-6 col-sm-3 sidebar-offcanvas equal-height\">
    		<ul class=\"nav nav-pills nav-stacked\">
    			#{secondary_tabs_list_items *args}
    		</ul>
     </aside>".html_safe
  end
end
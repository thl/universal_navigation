module UniversalNavigationHelper

  def primary_tabs_list
    [
      {
        :id => :places,
        :title => "Places",
        :app => :places,
        :url => defined?(PlacesResource.get_url) ? PlacesResource.get_url : false
      },
      {
        :id => :topics,
        :title => "Topics",
        :app => :topics,
        :url => defined?(TopicalMapResource.get_url) ? TopicalMapResource.get_url : false
      },
      {
        :id => :media,
        :title => "Media",
        :app => :media,
        :url => defined?(MediaManagementResource.get_url) ? MediaManagementResource.get_url : false
      },
      {
        :id => :dictionary,
        :title => "Dictionary",
        :app => :dictionary,
        :url => defined?(DictionaryResource.get_url) ? DictionaryResource.get_url : false
      }
    ]
  end
  
  def secondary_tabs_list
    [
      {
        :id => :places,
        :title => "Places",
        :app => :places,
        :url_method => :places_url,
        :count_method => :feature_count
      },
      {
        :id => :topics,
        :title => "Topics",
        :app => :topics,
        :url_method => :kmaps_url,
        :count_method => :category_count,
        #:count_method_args => {:cumulative => true}
      },
      {
        :id => :pictures,
        :title => "Pictures",
        :app => :media,
        :url_method => :pictures_url,
        :count_method => :media_count,
        :count_method_args => {:type => 'Picture'}
      },
      {
        :id => :videos,
        :title => "Videos",
        :app => :media,
        :url_method => :videos_url,
        :count_method => :media_count,
        :count_method_args => {:type => 'Video'}
      },
      {
        :id => :documents,
        :title => "Texts",
        :app => :media,
        :url_method => :documents_url,
        :count_method => :media_count,
        :count_method_args => {:type => 'Document'}
      }
    ]
  end
  
  def primary_tabs_list_items(current_tab_id)
    primary_tabs_list.collect{|tab|
      tab_id = tab[:id]
      if current_tab_id == tab_id
        "<li class='ui-state-active ui-tabs-selected'>
          <a><span>#{tab[:title]}</span></a>
        </li>"
      else
        "<li class='ui-tabs-unselected'>
          <a href='#{tab[:url]}'><span>#{tab[:title]}</span></a>
        </li>"
      end
    }.join("\n\t\t")
  end

  #
  # The custom_secondary_tabs argument should be an array like [[:place, "Place", feature_url(f.fid)],
  # [:related, "Related", related_features_url(f)]]
  #
  def secondary_tabs_list_items(current_app_id, current_tab_id, custom_secondary_tabs)
    @tab_options ||= {}
    tabs = [[:home, "Home", "#{ActionController::Base.relative_url_root}/"]] + custom_secondary_tabs
    unless @tab_options[:entity].blank?
      entity = @tab_options[:entity]
      secondary_tabs_list.each{|tab|
        # Only show tabs from other apps (so that Topics doesn't show up in Kmaps, for example)
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
            tabs << [tab[:id], "#{tab[:title]} (#{count})", url] if count > 0
          end
        end
      }
    end
      
    tabs.collect{|tab|
      tab_id = tab[0]
      title = tab[1]
      url = tab[2]
      if current_tab_id == tab_id
        "<li class='ui-state-active ui-tabs-selected'>
          <a><span>#{title}</span></a>
        </li>"
      else
        "<li class='ui-tabs-unselected'>
          <a href='#{url}'><span>#{title}</span></a>
        </li>"
      end
    }.join("\n\t\t")
  end

  #
  # Returns the HTML for creating the tabs.  Currently only accepts a block instead of a string
  #
  def universal_navigation(*args, &block)
    if block_given?
      primary_tab_id = args[0]
      secondary_tab_id = args[1]
      custom_secondary_tabs = args[2] || []
      options = args[3] || {}
      
      concat("
        <div id='universal_navigation' class='ui-tabs'>
        
      		<ul class='primary-tabs ui-tabs-nav'>
      			#{primary_tabs_list_items primary_tab_id}
      		</ul>
    		  
      		<ul class='secondary-tabs ui-tabs-nav'>
      			#{secondary_tabs_list_items primary_tab_id, secondary_tab_id, custom_secondary_tabs}
      		</ul>
    		
      		<div id='universal_navigation_content' class='ui-tabs-panel'>
      	    #{capture(&block)}
      	  </div>
    	  
      	</div>
      ")
    end
  end

  def stylesheet_files
    super + ['universal_navigation']
  end

end
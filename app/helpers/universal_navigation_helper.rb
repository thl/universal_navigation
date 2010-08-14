module UniversalNavigationHelper
  
  #
  # Tab configuration
  #
  # :id         The unique identifier that is used in references to the tab
  # :title      The text that appears in the top of the tab
  # :subdomain  The subdomain/app that this tab corresponds to
  # :path       The landing page for this tab
  # :tabs       A hash that defines the subdomains and paths of the other tabs that should be loaded when an entity of id ":id" is
  #             loaded in this tab.
  #               <key>          The :id of each tab, as defined above
  #               :subdomain     The subdomain that each tab corresponds to
  #               :home_path     The landing page for each tab
  #               :entity_path   The path that should be used for each tab when the current page shows an entity of id ":id"
  #
  def un_tabs
    [
      # This will eventually be a universal "Search" tab that lets you search all apps
      #{
      #  :id => :search,
      #  :title => "Search",
      #  :subdomain => :search,
      #  :path => "/",
      #  :tabs => {
      #    :media => {:subdomain => :media, :home_path => "/", :entity_path => "/"},
      #    :places => {:subdomain => :places, :home_path => "/", :entity_path => "/"},
      #    :topics => {:subdomain => :topics, :home_path => "/", :entity_path => "/"}
      #  }
      #},
      {
        :id => :places,
        :title => "Places",
        :subdomain => :places,
        :path => "/",
        :tabs => {
          :media => {:subdomain => :media, :home_path => "/", :entity_path => "/places/:id"},
          :topics => {:subdomain => :topics, :home_path => "/", :entity_path => "/places/:id"}
        },
        :entity_id_method => :fid
      },
      {
        :id => :topics,
        :title => "Topics",
        :subdomain => :topics,
        :path => "/",
        :tabs => {
          :media => {:subdomain => :media, :home_path => "/", :entity_path => "/topics/:id"},
          :places => {:subdomain => :places, :home_path => "/", :entity_path => "/topics/:id"}
        }
      },
      {
        :id => :media,
        :title => "Media",
        :subdomain => :media,
        :path => "/",
        :tabs => {
          :topics => {:subdomain => :topics, :home_path => "/", :entity_path => "/media_objects/:id"},
          :places => {:subdomain => :places, :home_path => "/", :entity_path => "/media_objects/:id"}
        }
      }
    ]
  end
  
  #
  # Hostname configuration for each tab
  #      
  def un_environment_subdomains
    {
      :media => {
        :production => "mms.thlib.org",
        :staging => "staging.mms.thlib.org",
        :development => "dev.mms.thlib.org",
        :local => "localhost:3002"
      },
      :places => {
        :production => "places.thlib.org",
        :staging => "staging.places.thlib.org",
        :development => "dev.places.thlib.org",
        :local => "localhost:3000"
      },
      :topics => {
        :production => "tmb.thlib.org",
        :staging => "staging.tmb.thlib.org",
        :development => "dev.tmb.thlib.org",
        :local => "localhost:3001"
      }
    }
  end
  
  #
  # Returns the current environment
  #
  def un_get_environment
    hostname = Socket.gethostname.downcase
    if hostname == 'dev.thlib.org'
      environment = :development
    elsif hostname == 'sds6.itc.virginia.edu'
      environment = :staging
    elsif hostname.ends_with? 'local'
      environment = :local
    else
      environment = :production
    end
    environment
  end
  
  #
  # Given a subdomain and optional path, get the full URL
  #
  def un_url(subdomain, path="", entity_id=false)
    # Need to find a way to get root URLs from .get_url instead of un_environment_subdomains, even for the
    # current app's own subdomain (e.g. in the PD, PlacesResource doesn't exist)
    #subdomain_hostname = case subdomain
    #  when :places then PlacesResource.get_url
    #  when :media then MediaManagementResource.get_url
    #  else un_environment_subdomains[subdomain][un_get_environment]
    #end
    subdomain_hostname = un_environment_subdomains[subdomain][un_get_environment]
    path.sub!(":id", entity_id.to_s) if entity_id
    "http://#{subdomain_hostname}#{path}"
  end
    
  #
  # For use with the JavaScript class, which needs to have the un_tabs hashes with tabs' URLs added to it 
  #
  def un_tabs_with_urls
    un_tabs.collect{|tab|
      tab[:tabs].each{|key, tab_info|
        tab[:tabs][key][:url] = un_url(tab_info[:subdomain], tab_info[un_path_type])
      }
      tab
    }
  end
  
  #
  # Determines whether the home path or the entity path should be used
  #
  def un_path_type
    un_entity ? :entity_path : :home_path
  end
  
  #
  # Returns the active entity, if it exists (it needs to be specified in @un_options[:entity] to exist)
  #
  def un_entity
    @un_options ||= {}
    @un_options[:entity].blank? ? false : @un_options[:entity]
  end
  
  #
  # Returns an array of the tab URLs given these arguments.  Can this be removed?
  #
  def get_tab_urls_for(subdomain, model, id)
    un_tabs.collect{|tab|
      "#{un_url(tab[:id])}"
    }
  end
  
  #
  # Returns the HTML for creating the tabs.  Currently only accepts a block instead of a string
  #
  def universal_navigation_tabs(*args, &block)
    if block_given?
      options = args.first || {}
      options[:current_tab] ||= :places
      
      @un_options ||= {}
      
      # Allow the active tab to be overwritten from within a controller or view, like:
      # @un_options[:current_tab] = :places
      options[:current_tab] = @un_options[:current_tab] unless @un_options[:current_tab].nil? 
      concat("
      
      <script type='text/javascript'>
        var universal_navigation;
        jQuery(document).ready(function(){
          universal_navigation = new UniversalNavigation();
        	universal_navigation.init('universal_navigation', {
        	  tabs: #{un_tabs_with_urls.to_json},
        	  selectedTabId: '#{options[:current_tab]}',
        		selectedIndex: #{get_tab_index_by_id options[:current_tab]}
        	});
        });
      </script>
      
      <div id='universal_navigation'>
      
    		<ul>
    			#{un_tab_list_items options[:current_tab]}
    		</ul>
    		
    	  #{un_tab_divs options[:current_tab], capture(&block)}
    	  
    	</div>
      ")
    end
  end
  
  #
  # Creates the HTML for secondary tabs.  Usage:
  # un_secondary_tabs([[first_tab_path, first_tab_name], [second_tab_path, second_tab_name], etc...], 2)
  # The selected_index is zero-counted.
  #
  def un_secondary_tabs(tabs, selected_index=0)
    list_items = tabs.collect{|t| "<li><a href=\"#{t[1]}\"><span>#{t[0]}</span></a></li>"}.join("\n")
    "<ul>
       #{list_items}
     </ul>
     <script type=\"text/javascript\">
       jQuery(document).ready(function(){
       	 universal_navigation.initSecondaryTabs({selectedIndex: #{selected_index}});
       });
     </script>
     	"
  end
  
  def javascript_files
    super + ['universal-navigation']
  end
    
  def stylesheet_files
    super + ['universal_navigation']
  end
  
  #
  # Returns the <li> elements that make up the tab tops
  #
  def un_tab_list_items(active_tab_id=:places)
    @un_options ||= {}
    active_tab = get_tab_by_id(active_tab_id)
    active_tab_related_tabs = active_tab[:tabs]
    entity_id_method = active_tab[:entity_id_method].blank? ? :id : active_tab[:entity_id_method].to_sym
    un_tabs.collect{|tab|
      tab_id = tab[:id]
      if active_tab_id == tab_id
        href = "#universal_tabs_#{active_tab_id}"
      else
        entity_id = un_entity ? un_entity.send(entity_id_method) : nil
        href = un_url(tab[:subdomain], active_tab_related_tabs[tab_id][un_path_type], entity_id)
      end
      # For getting counts of related entities (not yet implemented)
      #if un_entity
      #  related_entities_method = @un_options[:related_entities_method].blank? ? tab[:subdomain] : @un_options[:related_entities_method].to_sym
      #  if un_entity.respond_to? related_entities_method
      #    related_entities_count = un_entity.send(related_entities_method).length
      #  end
      #end
      #"<li>
      #  <a href='#{href}'><span>#{tab[:title]}#{' ('+related_entities_count.to_s+')' unless related_entities_count.nil?}</span></a>
      #</li>"
      "<li>
        <a href='#{href}'><span>#{tab[:title]}</span></a>
      </li>"
    }.join("\n\t\t")
  end
  
  #
  # Returns the <div> elements that make up the tabs' content
  #
  def un_tab_divs(active_tab_id, block)
    active_tab_id ||= :places
    un_tabs.collect{|tab|
      "<div id='universal_tabs_#{tab[:id]}'>
        #{block if active_tab_id == tab[:id]}
      </div>"
    }.join("\n\t\t")
  end
  
  #
  #
  #  
  def get_tab_by_id(id)
    un_tabs.each do |tab|
      return tab if tab[:id] == id
    end
    false
  end
  
  #
  #
  #  
  def get_tab_index_by_id(id)
    i = 0
    un_tabs.each do |tab|
      return i if tab[:id] == id
      i += 1
    end
    false
  end
  
  #
  # This can be called from controllers or views to change the path of the tab's link:
  # set_un_tab_path :places, "/features/59/media_objects"
  #
  def set_un_tab_path(tab_id, path)
    @un_options ||= {}
    @un_options[:tab_paths] ||= {}
    @un_options[:tab_paths][tab_id] = path
  end
end
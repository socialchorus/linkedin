module LinkedIn
  module Api

    module QueryMethods

      def profile(options={})
        path = person_path(options)
        simple_query(path, options)
      end

      def connections(options={})
        path = "#{person_path(options)}/connections"
        simple_query(path, options)
      end

      def network_updates(options={})
        path = "#{person_path(options)}/network/updates"
        simple_query(path, options)
      end

      def company(options = {})
        path   = company_path(options)
        simple_query(path, options)
      end

      def company_updates(options={})
        path = "#{company_path(options)}/updates"
        simple_query(path, options)
      end

      def company_statistics(options={})
        path = "#{company_path(options)}/company-statistics"
        simple_query(path, options)
      end

      def company_updates_comments(update_key, options={})
        path = "#{company_path(options)}/updates/key=#{update_key}/update-comments"
        simple_query(path, options)
      end

      def company_updates_likes(update_key, options={})
        path = "#{company_path(options)}/updates/key=#{update_key}/likes"
        simple_query(path, options)
      end

      def job(options = {})
        path = jobs_path(options)
        simple_query(path, options)
      end

      def job_bookmarks(options = {})
        path = "#{person_path(options)}/job-bookmarks"
        simple_query(path, options)
      end

      def job_suggestions(options = {})
        path = "#{person_path(options)}/suggestions/job-suggestions"
        simple_query(path, options)
      end

      def group_memberships(options = {})
        path = "#{person_path(options)}/group-memberships"
        simple_query(path, options)
      end

      def group_profile(options)
        path = group_path(options)
        simple_query(path, options)
      end

      def group_posts(options)
        path = "#{group_path(options)}/posts"
        simple_query(path, options)
      end

      def shares(options={})
        path = "#{person_path(options)}/network/updates"
        simple_query(path, {:type => "SHAR", :scope => "self"}.merge(options))
      end

      def share_comments(update_key, options={})
        path = "#{person_path(options)}/network/updates/key=#{update_key}/update-comments"
        simple_query(path, options)
      end

      def share_likes(update_key, options={})
        path = "#{person_path(options)}/network/updates/key=#{update_key}/likes"
        simple_query(path, options)
      end

      def picture_urls(options={})
        picture_size = options.delete(:picture_size) || 'original'
        path = "#{picture_urls_path(options)}::(#{picture_size})"
        simple_query(path, options)
      end

      private

      def group_path(options)
        path = "/groups"
        if options.has_key?(:id)
          path += "/#{options.fetch(:id)}"
        else
          # Use default path
        end
        path
      end

      def simple_query(path, options={})
        request_params = extract_request_params(options)

        if request_params.fetch(:public?)
          path +=":public"
        elsif request_params.fetch(:fields)
          mapped_fields = request_params.fetch(:fields).map do |f|
            f.to_s.gsub("_","-")
          end
          path +=":(#{mapped_fields.join(',')})"
        end

        headers = request_params.fetch(:headers)
        params = to_query(request_params.fetch(:params))
        path   += "#{path.include?("?") ? "&" : "?"}#{params}" if !params.empty?

        Mash.from_json(get(path, headers))
      end

      def extract_request_params(options)
        fields = options.fetch(:fields, LinkedIn.default_profile_fields)

        pub = !!options.fetch(:public, false)

        headers = options.fetch(:headers, {})

        params = options.reject do |k,_|
          [:domain, :is_admin, :name, :id, :public, :fields, :headers].include?(k)
        end

        {
          :fields => fields,
          :public? => pub,
          :headers => headers,
          :params => params
        }
      end

      def person_path(options)
        path = "/people/"
        if options.has_key?(:id)
          path += "id=#{options.fetch(:id)}"
        elsif options.has_key?(:url)
          path += "url=#{CGI.escape(options.fetch(:url))}"
        else
          path += "~"
        end
      end

      def company_path(options)
        path = "/companies"

        if options.has_key?(:domain)
          path += "?email-domain=#{CGI.escape(options.fetch(:domain))}"
        elsif options.has_key?(:id)
          path += "/id=#{options.fetch(:id)}"
        elsif options.has_key?(:url)
          path += "/url=#{CGI.escape(options.fetch(:url))}"
        elsif options.has_key?(:name)
          path += "/universal-name=#{CGI.escape(options.fetch(:name))}"
        elsif options.has_key?(:is_admin)
          path += "?is-company-admin=#{CGI.escape(options.fetch(:is_admin))}"
        else
          path += "/~"
        end
      end

      def picture_urls_path(options)
        path = person_path(options)
        path += "/picture-urls"
      end

      def jobs_path(options)
        path = "/jobs"
        if options.has_key?(:id)
          path += "/id=#{options.fetch(:id)}"
        else
          path += "/~"
        end
      end
    end
  end
end

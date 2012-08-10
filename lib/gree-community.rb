# -*- coding:utf-8 -*-

require 'uri'
require 'mechanize'

module GREE
  class Community
    def initialize id
      @id=id
    end
    attr_reader :id
    attr_reader :recent_threads
    def recent_threads_uri
      URI.parse(
        "http://gree.jp/?mode=community&act=bbs_list&community_id=#{id}"
      )
    end
    def fetch(fetcher)
      page=fetcher.get(recent_threads_uri)
      @recent_threads=page.search('.feed .item').map{|item|
        thread_uri = item.at('.head a').attr(:href)
        thread_uri =~ /&thread_id=(\d+)/
        thread_id = Integer($1)
        thread_title = item.at('.head a strong').text
        Thread.new(
          thread_id,
          title: thread_title,
        )
      }
    end
    class Thread
      def initialize(id,values={})
        @id=id
        @recent_comments=values[:recent_comments]
        @title=values[:title]
      end
      attr_reader :id
      attr_reader :recent_comments
      attr_reader :title
      def uri
        URI.parse(
          "http://gree.jp/?mode=community&act=bbs_view&thread_id=#{self.id}"
        )
      end
      def fetch(fetcher)
        page=fetcher.get(self.uri)
        @title = page.at('.title').text
        @recent_comments = page.search('.comment-list li').map{|comment|
          id = Integer(comment.attr(:id))
          body = comment.
            at('.item').
            children[3..-1]
          Comment.new(
            id,
            user_name: comment.at('.item strong').text,
            body_text: body.map{|elm| elm.name == 'br' ? "\n" : elm.text }.join('').gsub(//,''),
            time: Time.strptime(comment.at('.shoulder .timestamp').text, '%m/%d %H:%M'),
          )
        }
        nil
      end
      class Comment
        def initialize(id, values={})
          @id=id
          @body_text = values[:body_text]
          @user_name = values[:user_name]
          @time = values[:time]
        end
        attr_reader :id
        attr_reader :user_name
        attr_reader :body_text
        attr_reader :time
      end
    end
    class Fetcher
      USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/22.0.1207.1 Safari/537.1'
      def initialize user_id, password
        @user_id = user_id
        @password = password
        @agent = Mechanize.new
        @agent.user_agent = USER_AGENT
      end
      def get(uri)
        raise "invalid arg" unless uri.host == 'gree.jp'
        page_encoding = 'EUC-JP-MS'

        page = @agent.get(uri)
        page.encoding = page_encoding
        unless page.uri == uri
          login_form = page.form_with(name: 'login')
          raise "Login form not found: uri=#{uri} redirected=#{page.uri}" unless login_form

          login_uri = page.uri

          login_form.user_mail = @user_id
          login_form.user_password = @password
          login_form.submit

          page = @agent.page
          page.encoding = page_encoding

          raise "Login failed or something: uri=#{uri} login=#{login_uri} last=#{page.uri}" unless page.uri == uri
        end
        page
      end
    end
  end
end

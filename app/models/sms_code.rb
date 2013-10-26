#coding: utf-8
require 'net/http'

class SmsCode
	class << self
		def api_url
			'http://www.tui3.com'
		end

		def app_key
			'5becf5ec8c51836c1fe102430d2b7dff'
		end

		def format
			'json'			# 支持json和xml两种格式
		end

		def product_id
			2						# 1:推信 | 2:推信DIY
		end

		# def send(mobiles, content, encode = :utf8)
		# 	uri = "/api/send/?k=#{app_key}&r=#{format}&p=#{product_id}&t=#{mobiles}"
		# 	if encode == :utf8
		# 		uri << "&c=#{content}"
		# 	end
		# 	if encode == :gbk
		# 		uri << "&cn=#{content}"
		# 	end
		# 	url = URI.parse(api_url)
	 #    Net::HTTP.start(url.host, url.port) {|http|
	 #      response = http.get(uri)
	 #      p response.body
	 #    }
		# end

		# def send
		# 	puts '--send--'
		# end

		def balance
			uri = "/api/query/?k=#{app_key}&r=#{format}"
			url = URI.parse(api_url)
	    Net::HTTP.start(url.host, url.port) {|http|
	      response = http.get(uri)
	      p response.body
	    }
		end
	end
end
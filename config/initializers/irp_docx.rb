#coding: utf-8
require 'zipruby'
require 'fastimage'

module Irp
	class Docx
		attr_reader :template_path
		attr_reader :streams

		def initialize(template_path)
			@template_path = template_path
			@streams ||= Hash.new
			read_template
		end

		def generate_file(file_name = "output_#{Time.now.strftime("%Y-%m-%d_%H%M")}.docx")
	    buffer = generate_zip_in_memory
	    File.open(file_name, 'w') { |f| f.write(buffer) }
	  end

		def body
			key = 'word/document.xml'
			if block_given?
				yield Processor.new(self, key, streams[key])
			else
				streams[key]
			end
		end

		def add_file_bytes(key, stream)
			streams[key] = stream
		end

		def add_image_content_type(path)
			key = '[Content_Types].xml'
			stream = streams[key]
			ext = File.extname(path).sub('.', '')
			unless has_content_type?(stream, ext)
				index = stream.index('</Types>')
				stream.insert(index, %Q(<Default Extension="#{ext}" ContentType="image/#{ext}"/>))
			end
		end

		def add_image_relation_ship(path)
			ext = File.extname(path)
			key = 'word/_rels/document.xml.rels'
			stream = streams[key]
			id = max_relation_ship_id(stream)
			basename = "#{id}#{ext}"
			index = stream.index('</Relationships>')
			stream.insert(index, %Q(<Relationship Id="rId#{id}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/#{basename}"/>))
			File.open(path) do |file|
				add_file_bytes("word/media/#{basename}", file.read)
			end
			id
		end

		def generate_zip_in_memory
			buffer = ''
			Zip::Archive.open_buffer(buffer, Zip::CREATE) do |archive|
				streams.each do |key, stream|
					archive.add_buffer(key, stream)
				end
			end
			buffer
		end

		private
		def read_template
		  Zip::Archive.open(template_path) do |archive|
		  	archive.each do |f|
		  		add_file_bytes(f.name, f.read)
		  	end
		  end
		end

		def has_content_type?(stream, ext)
			!!(stream =~ /Extension=\"#{ext}\"/)
		end

		def max_relation_ship_id(stream)
			stream.scan(/<Relationship\s+Id=\"rId(\d+)\".*?\/>/).flatten.max.to_i + 1
		end
	end

	class Processor
		attr_reader :instance
		attr_reader :key
		attr_reader :stream

		def initialize(instance, key, stream)
			@instance = instance
			@key = key
			@stream = stream
		end

		def replace_tag(name, value, options = {})
			value = '' if (value.nil? || value.empty?)
			font_face = options[:font_face]
			font_size = options[:font_size] || 20
			stream.gsub!(/<w:bookmarkStart w:id=\"\d+\" w:name=\"#{name}\"\/><w:bookmarkEnd w:id=\"\d+\"\/>/) do |item|
				if font_face
					font_face = font_face.unpack('H*').pack('H*')
					item = %Q(<w:r><w:rPr><w:rFonts w:ascii="#{font_face}" w:eastAsia="#{font_face}" w:hint="eastAsia"/><w:sz w:val="#{font_size}"/></w:rPr><w:t>#{value.unpack('H*').pack('H*')}</w:t></w:r>)
				else
					item = %Q(<w:r><w:rPr><w:rFonts w:hint="eastAsia"/><w:sz w:val="#{font_size}"/></w:rPr><w:t>#{value.unpack('H*').pack('H*')}</w:t></w:r>)
				end
			end
			instance.add_file_bytes(key, stream)
		end

		def replace_img_tag(name, path)
			instance.add_image_content_type(path)
			id = instance.add_image_relation_ship(path)
			width, height = FastImage.size(path)
			cx = 3925900
			cy = 2286000
			# cx = width * 9460
			# cy = height * 9525
			stream.gsub!(/<w:bookmarkStart w:id=\"\d+\" w:name=\"#{name}\"\/><w:bookmarkEnd w:id=\"\d+\"\/>/) do |item|
				item = %Q(<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="#{cx}" cy="#{cy}"/><wp:docPr id="#{id}" name="#{name}" descr=""/><wp:cNvGraphicFramePr><a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/></wp:cNvGraphicFramePr><a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:nvPicPr><pic:cNvPr id="#{id}" name="#{name}"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="rId#{id}" cstate="print"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:ext cx="#{cx}" cy="#{cy}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>)
			end
		end
	end
end
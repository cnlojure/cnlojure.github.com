yuic = 'yuicompressor-2.4.6'
yuicjar = "#{yuic}.jar"

def compress_css(source, target)
  sh "java -jar 'bin/yuicompressor-2.4.6.jar' --type css " +
    "--charset utf-8 -o #{target} \"#{source}\""
end

task :default => :site

directory 'bin'

file "bin/#{yuicjar}" => 'bin' do
  sh "cd /tmp && wget http://yui.zenfs.com/releases/yuicompressor/#{yuic}.zip"
  sh "cd /tmp && unzip #{yuic}.zip"
  rm "/tmp/#{yuic}.zip"
  mv "/tmp/#{yuic}/build/#{yuicjar}", "bin/"
end

directory 'css'

less = FileList['less/**/*.less'].exclude('less/**/*.inc.less')

less.each do |source|
  target = source.sub(/less$/, 'css.fat').sub(/^less/, 'css')
  file target => (['css'] + FileList['less/**/*.less']) do
    sh "lessc #{source} #{target}"
  end
end

css = less.map {|f| f.sub(/less$/, 'css').sub(/^less/, 'css')}
css.each do |c|
  file c => ["#{c}.fat", "bin/#{yuicjar}"] do |t|
    compress_css "#{t.name}.fat", "#{t.name}"
  end
end

"Generate CSS files from LESS source."
task :less => css
task :open do
	 sh "ruby clojure_toolbox.rb"
end
task :site => :less do
  sh 'jekyll'
end

task :watch do
  sh 'while inotifywait -r .; do rake; done'
end

task :deploy => :site do
  sh 'bin/deploy'
end


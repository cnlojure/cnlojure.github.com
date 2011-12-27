# -*- coding: utf-8 -*-
require 'open-uri'
libs={}
class Project
  attr_accessor :name
  attr_accessor :url
  def initialize(name,url)
    @name=name
    @url=url
  end
end
open("http://www.clojure-toolbox.com/") do |http|
  catalog="unknow"
  http.each_line do |line|
    if line=~/<h2>(.*)<\/h2>/
      libs[$1]||=[]
      catalog=$1
    elsif line=~/<li><a href="(.*)">(.*)<\/a><\/li>/
      libs[catalog] << Project.new($2,$1)
    end
  end
end

def fetch_project_url(url)
  open(url).read.scan(/<a href="(.*)">\1<\/a>/)[0][0]
end

open("http://clojure-libraries.appspot.com/") do |http|
  http.each_line do |line|
    catalog="unknow"
    line.scan(/<a href="(\/(category|show)\/\d+)">(.*?)<\/a>/).each do |x|
      if x[1]=="category"
        catalog=x[2]
        libs[catalog]||=[]
      elsif x[1]=="show"
        detail="http://clojure-libraries.appspot.com#{x[0]}"
        libs[catalog] << Project.new(x[2].sub(/&raquo;&nbsp;/,""),fetch_project_url(detail));
      end
    end
  end
end

File.open("open.markdown","w") do |f|
  f.write <<BEGIN 
---
layout: page
title: Clojure开源项目列表
nav_item: open
---
BEGIN
  libs.each do |catalog,projects|
    f.puts "## #{catalog}"
    f.puts ""
    projects.each do |proj|
      f.puts "[&nbsp;&raquo;#{proj.name}](#{proj.url})"
    end
    f.puts ""
  end
end



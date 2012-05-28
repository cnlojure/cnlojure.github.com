---
layout: page
title: 首页
nav_item: home
---

#介绍

本篇文档的主要目的是介绍Clojure语言本身的最佳实践

作者:

* [Dennis Zhuang](https://github.com/killme2008)

##第一条 避免使用分数

理由: ratio是Clojure引入的有别于Java的数值类型，分数的分子和分母默认都是用BigInteger，如无特殊要求，不要用Ration，通常来说浮点除法足够满足你的要求。

例子:

     user=> (def a (/ 5 2))
     #'user/a
     user=> (def b (/ 2 5))
     #'user/b
	 user=> (* a b)
     1N
     user=> (class (* a b))
     clojure.lang.BigInt
	 user=> (time (dotimes [_ 10000] (* a b)))
     "Elapsed time: 5.75 msecs"
	 
	 user=> (def a 2.5)
     #'user/a
     user=> (def b 0.4)
     #'user/b
     user=> (class (* a b))
     java.lang.Double
	 user=> (time (dotimes [_ 10000] (* a b)))
     "Elapsed time: 1.214 msecs"
	 
如果要做高精度的计算，你也应该使用decimal

     user=> (class 1M)
     java.math.BigDecimal


##第二条 适当使用元属性inline来提升性能

理由: 通过设置函数的元信息`:inline`可以在调用该函数的地方内联该函数，也就是将该函数完全按照`inline`指定的form展开，虽然会增大生成的ByteCode大小，但是如果函数频繁被调用，一定程度上可以提升性能。但是，个人建议只最常用的"短"函数做内联处理，其他优化交给JVM处理。现代JVM已经可以通过分析统计将hotspot代码做内联优化。

例子:clojure.core标准库里的很多函数都是设置了inline属性的，例如int这个函数

     user=> (source int)
     (defn int
       "Coerce to int"
       {
        :inline (fn  [x] `(. clojure.lang.RT (~(if *unchecked-math* 'uncheckedIntCast 'intCast) ~x)))
        :added "1.0"}
       [x] (. clojure.lang.RT (intCast x)))
	   

可以看到inline对应的值是一个类似宏的form，这个form将在该函数被调用的地方展开。内联处理都是在编译期进行的，如果编译器不支持内联处理，那么默认还是走函数的body调用。我们可以自己写一个myint跟标准的int做性能对比:

    user=> (def a 3.4)
    #'user/a
	user=> (defn myint [x] (. clojure.lang.RT (intCast x)))
    #'user/myint
	user=> (time (dotimes [n 10000] (int a)))
    "Elapsed time: 0.752 msecs"
	user=> (time (dotimes [n 10000] (myint a)))
    "Elapsed time: 1.128 msecs"
	
请注意，这里给出的结果都是多次测试(>3)取最小值。

##第三条 对于vector尽量使用peek而不是last来获取最后一个元素

理由: 对于vector来说，last是O(n)的复杂度,last函数的文档也告诉我们它的调用是线性时间，而peek则是一个时间复杂度O(1)的调用，类似取数组元素的操作。

例子:

     user=> (def a (vec (range 0 1000)))
     #'user/a
	 user=> (time (dotimes [_ 10000] (last a)))
     "Elapsed time: 301.731 msecs"
	 user=> (time (dotimes [_ 10000] (peek a)))
     user=> (peek a)
     999
     user=> (last a)
     999"Elapsed time: 1.297 msecs"
	 
	 
##第四条 写针对基本类型的排序函数

理由: 通常排序用sort函数是足够了，但是对于一些性能特别敏感的场景，sort函数就不是很合适，例如对基本类型(byte,int,long,float等)的排序。这是因为sort默认是使用`java.lang.Arrays.sort(object[] a,Comparator cmp)`方法来对对象数组进行排序，使用的归并排序算法，因为对于对象排序来说，要求排序是稳定的(认为相等的元素之间的相对顺序不能改变)。而对于基本类型来说，稳定性是不必要的，因此Arrays.sort还有一系列重载方法用于基本类型的排序。在Clojure里我们也可以写类似的函数。

例子: 写一个用于int类型集合的排序函数

     (defn qsort [coll]
       (if (seq coll)
         (let [^ints a (int-array (count coll) coll)]
           (. java.util.Arrays (sort a))
           (seq a))
           ()))
		   
     user=> (def c (shuffle (range 0 10000)))
     #'user/c
	 user=> (time (dotimes [_ 1000] (sort c)))
     "Elapsed time: 3305.539 msecs"
	 user=> (time (dotimes [_ 1000] (qsort c)))
     "Elapsed time: 961.735 msecs"
	 
当然，实际应用中需要根据集合的大小和排序情况来选择，这样的方式不一定是最好的。但是本条给出了一个可能是隐患的地方以及可能的改进方式。

##第五条 考虑用case替代cond和condp

TODO


    

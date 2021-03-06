<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cache="http://www.springframework.org/schema/cache"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/cache
        http://www.springframework.org/schema/cache/spring-cache.xsd">

    <cache:annotation-driven cache-manager="cacheManager"/>
    <#if cache=="ehcache">
    <bean id="ehcacheManager"
          class="org.springframework.cache.ehcache.EhCacheManagerFactoryBean">
        <property name="configLocation" value="classpath:cache/ehcache.xml" />
    </bean>

        <bean id="cacheManager" class="org.springframework.cache.ehcache.EhCacheCacheManager">
            <property name="cacheManager" ref="ehcacheManager" />
            <property name="transactionAware" value="true" />
        </bean>
    <#elseif cache=="memcached">
        <!--
            枚举类型要想注入到类中，一定要先使用org.springframework.beans.factory.config.FieldRetrievingFactoryBean类将枚举类型进行转换
            将DefaultHashAlgorithm.KETAMA_HASH转换为KETAMA_HASH这个bean，
            然后在要注入的bean中使用<property name="hashAlg" ref="KETAMA_HASH" />引用即可。
         -->
        <bean id="KETAMA_HASH" class="org.springframework.beans.factory.config.FieldRetrievingFactoryBean">
            <property name="staticField" value="net.spy.memcached.DefaultHashAlgorithm.KETAMA_HASH" />
        </bean>
        <bean id="memcachedClient" class="net.spy.memcached.spring.MemcachedClientFactoryBean">
            <!-- 一个字符串，包括由空格或逗号分隔的主机或IP地址与端口号 -->
            <property name="servers" value="192.168.1.111:11211" />
            <!-- 指定要使用的协议(BINARY,TEXT),默认是TEXT -->
            <property name="protocol" value="BINARY" />
            <!-- 设置默认的转码器(默认以net.spy.memcached.transcoders.SerializingTranscoder) -->
            <property name="transcoder">
                <bean class="net.spy.memcached.transcoders.SerializingTranscoder">
                    <property name="compressionThreshold" value="1024" />
                </bean>
            </property>
            <!-- 以毫秒为单位设置默认的操作超时时间 -->
            <property name="opTimeout" value="1000" />
            <property name="timeoutExceptionThreshold" value="1998" />
            <!-- 设置哈希算法 -->
            <property name="hashAlg" ref="KETAMA_HASH" />
            <!-- 设置定位器类型(ARRAY_MOD,CONSISTENT),默认是ARRAY_MOD -->
            <property name="locatorType" value="CONSISTENT" />
            <!-- 设置故障模式(取消，重新分配，重试)，默认是重新分配 -->
            <property name="failureMode" value="Redistribute" />
            <!-- 想使用Nagle算法，设置为true -->
            <property name="useNagleAlgorithm" value="false" />
        </bean>

        <!-- spring自己的缓存管理器，这里定义了缓存位置名称 ，即注解中的value -->
        <bean id="cacheManager" class="${packageName}.cache.MemcachedCacheManager">
            <property name="caches">
                <set>
                    <!-- 这里可以配置多个缓存 -->
                    <bean class="${packageName}.cache.MemcachedCache">
                        <property name="client" ref="memcachedClient" />
                        <property name="name" value="myCache"/>
                        <!-- myCache名称要在类或方法的注解中使用 -->
                    </bean>
                </set>
            </property>
        </bean>
    <#elseif cache=="redis">
        <bean id="poolConfig" class="redis.clients.jedis.JedisPoolConfig">
            <property name="maxIdle" value="300" />
            <property name="maxTotal" value="600" />
            <property name="maxWaitMillis" value="1000" />
            <property name="testOnBorrow" value="true" />
        </bean>

        <bean id="jedisConnectionFactory" class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
            <property name="hostName" value="127.0.0.1"/>
            <property name="password" value=""/>
            <property name="port" value="6379"/>
            <property name="poolConfig" ref="poolConfig"/>
        </bean>
        <bean id="redisTemplate" class="org.springframework.data.redis.core.StringRedisTemplate">
            <property name="connectionFactory"   ref="jedisConnectionFactory" />
        </bean>

        <!-- spring自己的缓存管理器，这里定义了缓存位置名称 ，即注解中的value -->
        <bean id="cacheManager" class="org.springframework.cache.support.SimpleCacheManager">
            <property name="caches">
                <set>
                    <!-- 这里可以配置多个redis -->
                    <bean class="${packageName}.cache.RedisCache">
                        <property name="redisTemplate" ref="redisTemplate" />
                        <property name="name" value="myCache"/>
                        <!-- myCache名称要在类或方法的注解中使用 -->
                    </bean>
                </set>
            </property>
        </bean>
    </#if>
</beans>
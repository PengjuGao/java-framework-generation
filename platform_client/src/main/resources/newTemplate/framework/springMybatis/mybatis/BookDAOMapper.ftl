<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<!--命名空间应该是对应接口的包名+接口名 -->
<mapper namespace="${packageName}.dao.BookDAO">
    <!--id应该是接口中的方法，结果类型如没有配置别名则应该使用全名称 -->
    <!--获得所有图书 -->
    <select id="getAllBooks" resultType="${packageName}.po.Book">
        SELECT id,title,price,publishDate from book
    </select>
    <!--获得图书对象通过编号 -->
    <select id="getBookById" resultType="${packageName}.po.Book">
        select id,title,price,publishDate from book where id=${r"#{id}"}
    </select>
    <!-- 增加 -->
    <insert id="add">
        insert into book(title,price,publishDate)
        values(${r"#{title}"},${r"#{price}"},${r"#{publishDate}"})
    </insert>
    <!-- 删除 -->
    <delete id="delete">
        delete from book where id=${r"#{id}"}
    </delete>
    <!-- 更新 -->
    <update id="update">
        update book set title=${r"#{title}"},price=${r"#{price}"},publishDate=${r"#{publishDate}"}
        where id=${r"#{id}"}
    </update>
</mapper>
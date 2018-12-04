package com.platform.client.factory.FrameworkFactory.impl;

import com.platform.client.factory.FrameworkFactory.Framework;
import com.platform.client.vo.FrameworkVo;
import org.springframework.stereotype.Service;

/**
 * Created by Administrator on 2016/10/28.
 * 只添加Hibernate框架
 */
@Service("hibernate")
public class FrameworkHibernate implements Framework {

    @Override
    public void add(FrameworkVo vo) {

    }
}
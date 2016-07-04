

select round(sum(a.pay_total / 100), 2) as sales,
       to_char(create_time, 'YYYY-MM-DD') as daytime
  from mall_order_info a
 where a.state in ( --'WAIT_BUYER_PAY',--待付款
                   'WAIT_SELLER_SEND_GOODS', --待发货
                   'WAIT_BUYER_CONFIRM_GOODS', --待收货
                   'WAIT_BUYER_EVALUATION', --待评价
                   'TRADE_COMMENT_OVER', --已评价
                   'TRADE_FINISHED') --已结单
 and a.create_time< trunc(sysdate)
 and a.create_time>trunc(sysdate)-180
 group by to_char(create_time, 'YYYY-MM-DD')
  order by daytime desc

----新增条件   

select ordertime, sum(pay_total), sum(m_num), count(distinct(outcode))
  from (select to_char(a.create_time, 'YYYY-MM-DD') AS ordertime,
               sum(b.real_price * b.num) as pay_total,
               sum(b.num) as m_num,
               nvl(a.parent_code, a.outer_code) as outcode
          from mall_order_info a
          JOIN mall_order_detail b
            on a.order_id = b.order_id
         where a.state in ( --'WAIT_BUYER_PAY', '待付款',
                           'WAIT_SELLER_SEND_GOODS', -- '待发货',
                           'WAIT_BUYER_CONFIRM_GOODS', -- '待收货',
                           'WAIT_BUYER_EVALUATION', --'待评价',
                           'TRADE_COMMENT_OVER', --'已评价',
                           --'TRADE_CLOSED', -- '已取消',
                           -- 'TRADE_REFUND', --- '已退款',
                           'TRADE_FINISHED' --, '已结单'
                           )
           and a.pay_time < trunc(sysdate)
           and a.pay_time >= trunc(sysdate) - 180
           and b.item_name not like '%保证金%'
           and b.item_name not like '%测试%'
           and b.sku not like '2%' --剔除洗衣服务
         group by to_char(a.create_time, 'YYYY-MM-DD'),
                 
                  nvl(a.parent_code, a.outer_code))
 group by ordertime
 order by ordertime desc


 -----新增至尊与公司员工

select t.order_id,
       t.user_id,
       t.outcode,
       t.state,
       t.pay_total,
       t.outer_code,
       t.daytime,
       t.sku,
       case when t.sku  in ('80000515','80000514','80000513') then '机洗套餐'
        when  t.sku in ('80000518','80000517','80000516') then '139至尊'
         when t.sku in ('10000921','10000920') then '79至尊' 
           else t.sku end,
       t.item_name,
       t.num,
       t.real_price,
       e.user_id
  from (select a.order_id,
               a.user_id,
               nvl(a.parent_code, a.outer_code) as outcode,
               a.state,
               a.pay_total,
               a.outer_code,
               to_char(create_time, 'YYYY-MM-DD') as daytime,
               b.sku,
               b.item_name,
               b.num,
               b.real_price
          from mall_order_info a
          join mall_order_detail b
            on a.order_id = b.order_id
         where a.create_time > to_date('2016-06-17', 'YYYY-MM-DD')
           and a.create_time < to_date('2016-06-18', 'YYYY-MM-DD')
           and a.state in ( --'WAIT_BUYER_PAY',--待付款
                           'WAIT_SELLER_SEND_GOODS', --待发货
                           'WAIT_BUYER_CONFIRM_GOODS', --待收货
                           'WAIT_BUYER_EVALUATION', --待评价
                           'TRADE_COMMENT_OVER', --已评价
                           'TRADE_FINISHED') --已结单
           and b.item_name not like '%保证金%'
           and b.item_name not like '%测试%'
           and b.sku not like '2%' --剔除洗衣服务
        ) t
  left join (select base.user_id, em.mobileno
               from mall_user_base base
               join (select t.mobileno
                      from CRM_OrG_EMPLOYEE t
                     where empstatus = 3
                       and outdate > sysdate
                       and mobileno is not null) em
                 on base.mobile = em.mobileno
              order by em.mobileno desc) e
    on e.user_id = t.user_id --公司员工的id

-------

select a.buy_time,a.amount ,a.user_id,a.state,a.card_id
  from mall_user_prepaid_package a where a.state!='wait_pay'
 group by a.user_id 

SELECT *        
   FROM (SELECT ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY buy_time DESC) rn,        
          amount      
         FROM mall_user_prepaid_package)        
  WHERE rn = 1  ;


  ----select 
tl.* ,pre.buy_time,
case when trunc(pre.buy_time)=to_DATE(tl.daytime,'YYYY-MM-DD') then 'today'
  WHEN pre.buy_time IS NULL THEN 'nobuy'
  else 'other' end ,
pre.amount
--pre.user_id
/*t.order_id,
       t.user_id,
       t.outcode,
       t.state,
       t.pay_total,
       t.outer_code,
       t.daytime,
       t.sku,
       t.pay_type,
     \*  case when t.sku  in ('80000515','80000514','80000513') then '机洗套餐'
        when  t.sku in ('80000518','80000517','80000516') then '139至尊'
         when t.sku in ('10000921','10000920') then '79至尊' 
           else t.sku end as gooditem,*\
       t.item_name,
       t.num,
       t.real_price,
       e.user_id,
       case when e.user_id is not null then '公司员工'
         else '非公司员工' end  as userid*/

from
(
select t.*,
      -- e.user_id as userid,
       case when e.user_id is not null then '公司员工'
         else '非公司员工' end  as userid
  from (select a.order_id,
               a.pay_type,
               a.user_id,
               nvl(a.parent_code, a.outer_code) as outcode,
               a.state,
               a.pay_total,
               a.outer_code,
               to_char(create_time, 'YYYY-MM-DD') as daytime,
               b.sku,
               b.item_name,
               b.num,
               b.real_price
          from mall_order_info a
          join mall_order_detail b
            on a.order_id = b.order_id
         where a.create_time > to_date('2016-06-17', 'YYYY-MM-DD')
           and a.create_time < to_date('2016-06-18', 'YYYY-MM-DD')
           and a.state in ( --'WAIT_BUYER_PAY',--待付款
                           'WAIT_SELLER_SEND_GOODS', --待发货
                           'WAIT_BUYER_CONFIRM_GOODS', --待收货
                           'WAIT_BUYER_EVALUATION', --待评价
                           'TRADE_COMMENT_OVER', --已评价
                           'TRADE_FINISHED') --已结单
           and b.item_name not like '%保证金%'
           and b.item_name not like '%测试%'
           and b.sku not like '2%' --剔除洗衣服务
        ) t
  left join 
  (select base.user_id, em.mobileno
               from mall_user_base base
               join (select t.mobileno
                      from CRM_OrG_EMPLOYEE t
                     where empstatus = 3
                       and outdate > sysdate
                       and mobileno is not null) em
                 on base.mobile = em.mobileno
              order by em.mobileno desc) e
    on e.user_id = t.user_id 
    ) tl --公司员工的id
left join(select a.buy_time,a.amount,a.user_id from  mall_user_prepaid_package a
select max(a.buy_time),a.amount,a.user_id from  mall_user_prepaid_package a group by a.user_id
 ) pre
on pre.user_id =tl.user_id ----包含了所有用户充值记录。


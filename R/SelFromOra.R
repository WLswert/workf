source('R/conOR.R')

###### save the sql string

sqlstr="
select tl.*,
       pre.buy_time,
case
when trunc(pre.buy_time) = tl.daytime  then
'today'
WHEN pre.buy_time IS NULL THEN
'nobuy'
else
'other'
end as carduse_type,
pre.amount--,
--pre.user_id
from (select t.*,
-- e.user_id as userid,
case
when e.user_id is not null then
'公司员工'
else
'非公司员工'
end as userid
from (
select t.* ,nvl(s.suite_name, t.item_name) as itemname,
nvl(s.suite_sku, t.sku) as itemsku
from
(select a.order_id,
a.pay_type,
a.user_id,
case when a.shipping_type='since'and a.province_name is null then '自提'
else a.province_name end as province_name ,
a.city_name,
a.pay_time,
a.create_time,
nvl(a.parent_code, a.outer_code) as outcode,
a.state,
a.pay_total,
a.outer_code,
-- to_char(create_time, 'YYYY-MM-DD') as daytime,
trunc(pay_time) as daytime,
trunc(pay_time,'mm') as monthtime,
b.sku,
/*  case when t.sku  in ('80000515','80000514','80000513') then '机洗套餐'
when  t.sku in ('80000518','80000517','80000516') then '139至尊'
when t.sku in ('10000921','10000920') then '79至尊'
else t.sku end as gooditem,*/
b.item_name,
b.num,
b.real_price
from mall_order_info a
join mall_order_detail b
on a.order_id = b.order_id
/*   where a.create_time > to_date('2016-06-17', 'YYYY-MM-DD')
and a.create_time < to_date('2016-06-18', 'YYYY-MM-DD')*/

where a.pay_time < trunc(sysdate)
and a.pay_time >= (case when (trunc(sysdate) - 180)>to_date('2016-01-01', 'YYYY-MM-DD') then (trunc(sysdate) - 180)
else  to_date('2016-01-01', 'YYYY-MM-DD') end)

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
left join (select suite_name, suite_sku
from mall_item_suite a
union
select product_name, product_sku
from mall_product_info b) s
on suite_sku = t.sku
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
on e.user_id = t.user_id) tl --公司员工的id
left join ( /*select a.buy_time, a.amount, a.user_id
from mall_user_prepaid_package a
select max(a.buy_time), a.amount, a.user_id
from mall_user_prepaid_package a
where a.state != 'wait_pay'
group by a.user_id ----包含了所有用户充值记录。*/
select *
from (select a.buy_time,
a.amount,
a.user_id,
-- a.state,
-- a.card_id,
row_number() over(partition by user_id order by buy_time desc) as rn
from mall_user_prepaid_package a
where a.state != 'wait_pay')
where rn = 1 ------用户的最近一次充值记录
) pre
on pre.user_id = tl.user_id
order by daytime asc

"



########## exec the sql
data=conOra(sqlstr)


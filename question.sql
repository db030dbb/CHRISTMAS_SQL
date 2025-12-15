/*
* =========================================================================================================
* | 1번 (2025.12.01)
* | 영화 제목에 'Love' 또는 'love'라는 글자가 포함된 영화의 제목과 개봉 연도, 평점을 조회하는 쿼리를 작성해주세요. 
* | 결과는 평점이 높은 순으로 정렬, 만약 평점이 같다면 개봉 연도가 최근인 영화부터 출력되어야 합니다.
* =========================================================================================================
*/

SELECT title, year, rating
FROM movies
where title = '%Love%' or title = '%love%'
ORDER BY rating DESC, year DESC;


/*
* =====================================================================================
* | 2번 (2025.12.02)
* | 2022년 12월 중 초미세먼지(PM2.5) 농도가 9㎍/㎥ 이하인 날을 출력하는 쿼리를 작성해주세요.
* | 컬럼명은 day로 날짜 컬럼 하나만 오름차순으로 출력해주세요.   
* =====================================================================================
*/

SELECT dates AS 'day'
FROM measurements
WHERE (dates BETWEEN '2022-12-01' and '2022-12-31') and pm2_5 <= 9
ORDER BY dates;


/*
* ============================================================================
* | 3번 (2025.12.03)
* | puppies 테이블에서 강아지의 종, 몸무게를 출력하는 쿼리를 작성해주세요.
* | 강아지의 종 또는 몸무게가 없는 데이터를 제외하고 출력해주세요.  
* | 몸무게가 무거운 순서로 출력, 몸무게가 같다면 종의 이름으로 오름차순 정렬해주세요.
* ============================================================================
*/
SELECT species, weights
FROM puppies
where species IS NOT NULL AND weights IS NOT NULL
ORDER BY weights DESC, species;


/*
* ============================================================================
* | 4번 (2025.12.05)
* | 2020년 12월 동안 모든 주문의 매출 합계가 1000$ 이상인 고객 ID를 출력하세요.
* ============================================================================
*/
SELECT customer_id
FROM records
WHERE strftime('%Y-%m', order_date) = '2020-12'
GROUP BY customer_id
HAVING sum(sales) >= 1000;


/*
* ==========================================================================================
* | 5번 (2025.12.05) -> 다시 풀어보기!
* | 금액이 25 달러 이상인 경우 스탬프를 2개, 15달러 이상인 경우 1개, 이외에는 스탬프를 찍어주지 않아요.
* | 영수증 별로 받을 스탬프 개수를 계산한 후 스탬프 개수 별로 영수증 개수를 집계하는 쿼리를 작성해주세요.
* | 스탬프 개수 기준 오름차순으로 정렬하고 스탬프 개수, 영수증 개수만 출력해주세요.
* ===========================================================================================
*/
SELECT 
    CASE 
        WHEN total_bill >= 25 THEN 2
        WHEN total_bill >= 15 THEN 1
        ELSE 0
    END AS stamp,
    COUNT(*) AS count_bill
FROM tips
GROUP BY stamp
ORDER BY stamp;


/*
* ==========================================================================================
* | 6번 (2025.12.06) 
* | 대여점의 활성 고객 중 대여 횟수가 35회 이상인 고객 ID 를 출력하는 쿼리를 작성하세요.
* ===========================================================================================
*/
SELECT customer_id
FROM (
  SELECT c.customer_id, count(rental_id) AS rental_cnt
  FROM customer as c
  LEFT JOIN rental as r ON c.customer_id = r.customer_id
  WHERE active = true
  GROUP BY c.customer_id )
WHERE rental_cnt >= 35;

# --- 더 쉬운 풀이 방법 ---
# 서브 쿼리 없이 HAVING 이용하기
SELECT c.customer_id
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.customer_id
WHERE c.active = true
GROUP BY c.customer_id
HAVING COUNT(rental_id) >= 35;


/*
* ==========================================================================================
* | 7번 (2025.12.08) 
* | 이틀 연속 미세먼지 수치가 증가하여 그 다음 날이 30㎍/㎥ 이상이 된 날을 추출하는 쿼리를 작성해주세요. 
* | 그 다음 날 추출
* ===========================================================================================
*/

SELECT measured_at 
FROM (SELECT measured_at, pm10, 
              LAG(measured_at) OVER (ORDER BY measured_at) AS yesterday,
              LAG(pm10) OVER (ORDER BY measured_at) AS yesterday_pm10, 
              LAG(measured_at, 2) OVER (ORDER BY measured_at) AS two,
              LAG(pm10,2) OVER (ORDER BY measured_at) AS two_pm10
  FROM measurements) AS bad30
WHERE julianday(measured_at) - julianday(yesterday) = 1
      AND julianday(measured_at) - julianday(two) = 2
      AND pm10 >= 30 AND two_pm10 < yesterday_pm10 AND yesterday_pm10 < pm10


/*
* ==========================================================================================
* | 8번 (2025.12.08) 
* | 아래 조건을 만족하는 와인 목록을 출력해주세요.
* | 1. 화이트 와인일 것
* | 2. 와인 품질 점수가 7점 이상일 것
* | 3. 밀도와 잔여 설탕이 와인 전체의 해당 성분 평균 보다 높을 것
* | 4. 산도가 화이트 와인 전체 평균보다 낮고, 구연산 값이 화이트 와인 전체 평균 보다 높을 것
* ===========================================================================================
*/
SELECT *
FROM wines
WHERE color = 'white'
  AND quality >= 7
  AND density > (SELECT AVG(density) FROM wines)
  AND residual_sugar > (SELECT AVG(residual_sugar) FROM wines)
  AND pH < (SELECT AVG(pH) FROM wines WHERE color = 'white')
  AND citric_acid > (SELECT AVG(citric_acid) FROM wines WHERE color = 'white')


  /*
* ==========================================================================================
* | 9번 (2025.12.09) 
* | 한국 국가대표팀으로 여자 배구 종목에 연속 2회 이상 참가한 선수 id와 이름을 출력하세요.
* ===========================================================================================
*/

# 다시 풀어보기
SELECT DISTINCT athlete_id AS id, name
FROM (
  SELECT athlete_id, name, year, 
        LAG(year) OVER (PARTITION BY athlete_id ORDER BY year) AS prev_year
  FROM records r
  JOIN events e ON r.event_id = e.id
  JOIN teams t ON r.team_id = t.id
  JOIN games g ON r.game_id = g.id
  JOIN athletes a ON r.athlete_id = a.id
  WHERE e.event = 'Volleyball Women''s Volleyball' 
    AND t.team = 'KOR') AS new_table
WHERE year - prev_year = 4


  /*
* ==========================================================================================
* | 10번 (2025.12.12) 
* | 한국 국가대표팀으로 여자 배구 종목에 참가한 선수 메달을 딴 선수의 id와 이름, 메달 종류를 출력하세요.
* ===========================================================================================
*/
# 쉼표 추가해야할 땐 GROUP_CONCAT(컬럼명, ', ') 이용 ('쉼표+공백' 이어야함)
# 중복 제거, 정렬도 하고 싶을 땐 GROUP_CONCAT(DISTINCT 컬럼명 ORDER BY 정렬 대상 SEPARATOR ', ') 이용 (SEPARATOR : 구분자를 지정 '쉼표+공백') -> MYSQL
# GROUP_CONCAT(DISTINCT medal, ', ') -> SQLite
SELECT ath.id, name, 
      GROUP_CONCAT(DISTINCT medal ORDER BY medal SEPARATOR ', ') AS medals
FROM athletes ath
JOIN records r ON ath.id = athlete_id
JOIN events e ON r.event_id = e.id
JOIN teams t ON r.team_id = t.id
WHERE event = 'Volleyball Women''s Volleyball' AND team = 'KOR'AND medal IS NOT NULL
GROUP BY ath.id, name


  /*
* ==========================================================================================
* | 11번 (2025.12.12) 
* | 토/일요일의 경우 'weekend', 다른 요일의 경우 'weekday' 로 변환 후 
* | 주중, 주말의 합계 매출 규모를 집계하는 쿼리를 작성해주세요. 
* | week, sales 컬럼이 있어야하고 매출 합계 기준 내림차순으로 정렬하세요.
* ===========================================================================================
*/

# day = 'Sat' OR day = 'Sun' THEN 'weekend' 이거 대신  WHEN day IN ('Sat', 'Sun') THEN 'weekend' 이것도 가능
SELECT
  CASE WHEN day = 'Sat' OR day = 'Sun' THEN 'weekend'
    ELSE 'weekday' END AS week, SUM(total_bill) AS sales
FROM tips
GROUP BY week
ORDER BY sales DESC

  /*
* ==========================================================================================
* | 12번 (2025.12.12) 
* | 게임 출시 연도 기준 2011년부터 2015년까지 각 장르의 점수 평균을 계산하는 쿼리를 작성해주세요.
* | 평균 점수가 없는 게임은 계산에서 제외되어야하고 소수점 아래 셋째 자리에서 반올림 해주세요.
* | 컬럼은 genere(장르 이름), score_2011(2011년 평균 점수), score_2012, score_2013, 
* |       score_2014, score_2015 가 있어야 합니다.
* ===========================================================================================
*/
WITH join_table AS (
  SELECT gm.year, gr.name, gm.critic_score
  FROM games gm
  JOIN genres gr ON gm.genre_id = gr.genre_id
  WHERE critic_score IS NOT NULL AND year BETWEEN 2011 AND 2015)

SELECT name AS genre,
  ROUND(AVG(CASE WHEN year = 2011 THEN critic_score END), 2) AS score_2011,
  ROUND(AVG(CASE WHEN year = 2012 THEN critic_score END), 2) AS score_2012,
  ROUND(AVG(CASE WHEN year = 2013 THEN critic_score END), 2) AS score_2013,
  ROUND(AVG(CASE WHEN year = 2014 THEN critic_score END), 2) AS score_2014,
  ROUND(AVG(CASE WHEN year = 2015 THEN critic_score END), 2) AS score_2015
FROM join_table
GROUP BY name


/*
* ==============================================================================================
* | 13번 (2025.12.15) 
* | 배우별 대여 매출 합계를 계산하고, 그 중 상위 5명 배우의 이름, 성, 총매출을 출력하는 쿼리를 작성해주세요. 
* ===============================================================================================
*/
SELECT first_name, last_name, SUM(amount) AS total_revenue
FROM actor a
LEFT JOIN film_actor f_a ON a.actor_id = f_a.actor_id
LEFT JOIN film f ON f_a.film_id = f.film_id
LEFT JOIN inventory i on f.film_id = i.film_id
LEFT JOIN rental r on i.inventory_id = r.inventory_id
LEFT JOIN payment p on r.rental_id = p.rental_id
GROUP BY a.actor_id
ORDER BY SUM(amount) DESC
LIMIT 5

/*
* ===============================================================================================
* | 14번 (2025.12.15) 
* |  작품, 연도 상관 없이 2회 이상 등재 / 해당 작가 작품들의 평균 사용자 평점이 4.5점 이상 
* |  / 해당 작가 작품들의 평균 리뷰 수가 소설 분야 작품들의 평균 리뷰 수 이상인 소설 작가 이름을 출력해주세요.
* ================================================================================================
*/
SELECT author
FROM books
WHERE genre = 'Fiction'
group by author
HAVING count(*) >= 2 AND AVG(user_rating) >= 4.5 AND AVG(reviews) >= (SELECT AVG(reviews) FROM books WHERE genre = 'Fiction' )
ORDER BY author


/*
* ===============================================================================================
* | 15번 (2025.12.15) 
* |  작품 중 한국 감독의 영화를 찾아, 감독 이름과 작품명을 출력하는 쿼리를 작성해주세요. 
* ================================================================================================
*/
# --- 정확한 문자열 외 문자열 포함 찾을땐 = 가 아니라 LIKE ---
SELECT name AS artist, title
FROM artworks w
JOIN artworks_artists aa on w.artwork_id = aa.artwork_id
JOIN artists t ON aa.artist_id = t.artist_id
WHERE classification LIKE 'Film%' AND nationality = 'Korean'
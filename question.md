# 1번 (2025.12.01)
영화 제목에 'Love' 또는 'love'라는 글자가 포함된 영화의 제목과 개봉 연도, 평점을 조회하는 쿼리를 작성해주세요. 결과는 평점이 높은 순으로 정렬되어 있어야 하고, 만약 평점이 같다면 개봉 연도가 최근인 영화부터 출력되어야 합니다.   

```
SELECT title, year, rating
FROM movies
where title = '%Love%' or title = '%love%'
ORDER BY rating DESC, year DESC;
```
   
---

# 2번 (2025.12.02)
좋은 날을 출력하는 쿼리를 작성해주세요. 2022년 12월 중 초미세먼지(PM2.5) 농도가 9㎍/㎥ 이하여야 합니다. 날짜 컬럼 하나만 오름차순으로 출력해주세요.   
```
SELECT measured_at AS 'good_day'
FROM measurements
WHERE (measured_at BETWEEN '2022-12-01' and '2022-12-31') and pm2_5 <= 9
ORDER BY measured_at;
```

> where 절 2022년 12월을 나타내는 다른 방법   
> 1. WHERE measured_at BETWEEN '2022-12-01' AND '2022-12-31'
> 2. WHERE measured_at >= '2022-12-01' AND measured_at <= '2022-12-31'
> 3. WHERE measured_at > '2022-11-31' AND measured_at < '2023-01-01'   
   
---

# 3번 (2025.12.03)
```
SELECT species, body_mass_g
FROM penguins
where species IS NOT NULL AND body_mass_g IS NOT NULL
ORDER BY body_mass_g DESC, species;
```

---


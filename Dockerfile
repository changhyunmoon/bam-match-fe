# 1단계: Build stage (React 빌드)
FROM node:18-alpine AS build
WORKDIR /app

# 캐시 효율을 위해 의존성 파일부터 복사
COPY package*.json ./
RUN npm install

# 전체 소스 복사 및 빌드
COPY . .
RUN npm run build

# 2단계: Production stage (Nginx 서빙)
FROM nginx:stable-alpine

# 컨테이너 내부의 기본 Nginx 설정 삭제
RUN rm /etc/nginx/conf.d/default.conf

# SPA 라우팅을 지원하는 Nginx 설정을 컨테이너 내부로 복사
# (프로젝트 루트에 있는 nginx.conf를 사용합니다)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 1단계 빌드 결과물을 Nginx 정적 파일 경로로 복사
COPY --from=build /app/build /usr/share/nginx/html

# 80포트 노출 및 Nginx 실행
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
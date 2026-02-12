# 1단계: Build stage (React 소스를 빌드하여 정적 파일 생성)
FROM node:18-alpine AS build
WORKDIR /app

# 의존성 설치 (캐시 활용을 위해 package.json 먼저 복사)
COPY package*.json ./
RUN npm install

# 전체 소스 복사 및 빌드
COPY . .
RUN npm run build

# 2단계: Production stage (빌드된 파일을 Nginx로 서빙)
FROM nginx:stable-alpine

# 컨테이너 내부의 Nginx 기본 설정 삭제 후 우리 설정 파일 복사
# (nginx.conf 파일은 나중에 만들 예정입니다)
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 1단계에서 빌드된 결과물(build 폴더)만 Nginx 실행 경로로 복사
COPY --from=build /app/build /usr/share/nginx/html

# 80포트 노출 및 Nginx 실행
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
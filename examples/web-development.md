# Web Development Examples

This document shows realistic examples of using `claude-task-plan` for web development tasks with specific project structures and requirements.

## Example 1: E-commerce Platform with React & Node.js

### Task Description
```bash
claude-task-plan "Build a complete e-commerce platform using React frontend and Node.js backend. Project structure: /src/frontend (React components), /src/backend (Express API), /src/database (MongoDB schemas). Features needed: product catalog with search/filters, shopping cart, checkout with Stripe integration, user authentication (JWT), admin dashboard for product management. Implement responsive design for mobile/desktop."
```

### What Claude Might Ask (Clarification Phase)
- "What payment methods besides Stripe do you need to support?"
- "Do you need inventory management or just product display?"
- "What authentication provider - custom JWT, Auth0, or Firebase Auth?"
- "Any specific React state management preference - Redux, Zustand, or Context API?"
- "What deployment target - Vercel, Netlify, AWS, or Docker containers?"

### Expected Success Criteria
- ✅ Complete React frontend with responsive design (mobile-first)
- ✅ RESTful API with proper authentication and authorization
- ✅ Product search with filters (category, price range, ratings)
- ✅ Shopping cart with persistent storage (localStorage + database)
- ✅ Stripe payment integration with webhook handling
- ✅ Admin dashboard with CRUD operations for products
- ✅ 95%+ Lighthouse performance score
- ✅ Security audit passing (OWASP top 10 compliance)

### Likely Agents Used
- `frontend-developer`: React components, state management, responsive UI
- `backend-architect`: Express.js API design, database schemas
- `payment-integration`: Stripe checkout flow and webhook implementation
- `security-auditor`: Authentication security and input validation
- `performance-engineer`: Bundle optimization and caching strategies

## Example 2: Real-time Analytics Dashboard

### Task Description
```bash
claude-task-plan "Create real-time analytics dashboard for web application metrics. Tech stack: Next.js 14 with TypeScript, PostgreSQL database, WebSocket connections. Data sources: /data/analytics/ directory with JSON files containing user events, page views, conversion data. Dashboard features: real-time visitor counter, conversion funnel visualization, geographic user distribution map, performance metrics charts. Deploy with Docker Compose for local development."
```

### What You'll Get
**Phase 1: Data Architecture**
- PostgreSQL schema design for analytics data
- Data ingestion pipeline from JSON files to database
- Real-time event processing with WebSocket integration
- Data validation and cleansing procedures

**Phase 2: Frontend Development**
- Next.js dashboard with TypeScript and Tailwind CSS
- Interactive charts using Chart.js or D3.js
- Real-time updates using WebSocket connections
- Responsive layout with mobile-optimized views

**Phase 3: DevOps & Deployment**
- Docker Compose setup for multi-container deployment
- Environment configuration for development/production
- Automated testing pipeline with Jest and Cypress
- Performance monitoring and error tracking setup

### Business Value
- Real-time insights into user behavior and system performance
- Data-driven decision making with interactive visualizations
- Scalable architecture supporting high-traffic applications

## Example 3: Content Management System (CMS)

### Task Description
```bash
claude-task-plan "Build headless CMS using Strapi backend and Next.js frontend. Project located in /projects/my-cms/ with structure: /backend (Strapi API), /frontend (Next.js site), /content (markdown files). Features: article management, media library, user roles (admin/editor/author), SEO optimization, multi-language support (English/Spanish). Content types: blog posts, pages, product descriptions. Deploy backend to Railway and frontend to Vercel."
```

### Detailed Workflow
**1. Requirements Clarification**
- Content modeling requirements and relationships
- User permission levels and workflow approval process
- SEO requirements and social media integration needs

**2. Backend Development**
- Strapi configuration with custom content types
- User role and permission system setup
- Media handling and image optimization
- API documentation with Swagger/OpenAPI

**3. Frontend Implementation**
- Next.js with static site generation (SSG)
- Dynamic routing for content pages
- SEO optimization with meta tags and structured data
- Internationalization (i18n) setup for multiple languages

**4. Integration & Testing**
- API integration with proper error handling
- Content preview functionality for editors
- Automated testing for critical user journeys
- Performance optimization and Core Web Vitals compliance

## Example 4: Progressive Web App (PWA)

### Task Description
```bash
claude-task-plan "Convert existing React application at /src/my-app/ to Progressive Web App with offline capabilities. Requirements: service worker for caching strategies, push notifications for user engagement, offline data sync with IndexedDB, responsive design optimized for mobile devices. App features: task management, calendar integration, file sharing. Target: installable PWA with 90+ PWA score in Lighthouse."
```

### Technical Implementation
**Service Worker Strategy:**
- Cache-first for static assets (CSS, JS, images)
- Network-first for API calls with offline fallback
- Background sync for data when connection restored

**Offline Capabilities:**
- IndexedDB for local data storage
- Conflict resolution for sync operations
- Offline UI indicators and messaging

**PWA Features:**
- App manifest with proper icons and metadata
- Installation prompts and app shortcuts
- Push notification subscription and handling

## Best Practices for Web Development Tasks

### 📋 Task Description Guidelines

**❌ Too Generic:**
```bash
claude-task-plan "Build a website"
```

**✅ Specific and Complete:**
```bash
claude-task-plan "Build portfolio website using Astro static site generator in /projects/portfolio/. Features: project showcase with filtering, blog section with markdown content, contact form with email integration, dark/light theme toggle. Deploy to Netlify with automated builds from GitHub. Optimize for Core Web Vitals and accessibility (WCAG 2.1 AA compliance)."
```

### 🎯 Include These Details

1. **Tech Stack**: Specific frameworks, libraries, and versions
2. **Project Structure**: Directory layout and file organization
3. **Feature Requirements**: Detailed functionality specifications
4. **Performance Goals**: Lighthouse scores, loading times, Core Web Vitals
5. **Deployment Target**: Hosting platform and CI/CD requirements
6. **Security Requirements**: Authentication, data validation, HTTPS

### 🚀 Success Indicators

- Code follows framework best practices and conventions
- Responsive design tested across device sizes
- Performance benchmarks met (Lighthouse > 90)
- Security vulnerabilities addressed (npm audit clean)
- Accessibility standards compliance (WCAG 2.1)
- Cross-browser compatibility verified

## Common Pitfalls to Avoid

❌ **Vague tech requirements**: "Build with React"
✅ **Specific stack**: "Build with React 18, TypeScript, Tailwind CSS, and Vite"

❌ **No performance goals**: "Make it fast"
✅ **Measurable targets**: "Achieve Lighthouse score >90 and First Contentful Paint <1.5s"

❌ **Missing project context**: "Add authentication"
✅ **Clear integration**: "Add JWT authentication to existing Express API at /api/auth/ with password reset functionality"

❌ **No deployment plan**: "Build the app"
✅ **Full deployment**: "Build and deploy to Vercel with automatic GitHub integration and preview deployments"
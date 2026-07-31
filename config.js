// ============================================================================
//  The ONLY line you edit here: the public address of your chatbot API.
//  (The chatbot API is the sibling `chatbot/` folder, once you deploy it.)
//
//  • Local testing (bot running on your Mac):  http://localhost:8000
//  • After you deploy the bot to Render:       https://your-bot-xxxx.onrender.com
// ============================================================================
const BACKEND_URL = "https://rag-chatbot-production-5fcc.up.railway.app";

// Which company on that server answers this page. The site names its tenant
// explicitly (/c/<slug>/chat) instead of using the server's default-host route,
// so a change to the server's COMPANY setting can never re-point this chat at
// somebody else's business.
const COMPANY_SLUG = "mybiz";

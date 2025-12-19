import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import "./index.css";


createRoot(document.getElementById("root")!).render(<App />);

// Registrar service worker para notificações push
if ('serviceWorker' in navigator) {
	window.addEventListener('load', () => {
		navigator.serviceWorker.register('/src/service-worker.js')
			.then(registration => {
				console.log('Service Worker registrado com sucesso:', registration);
			})
			.catch(error => {
				console.error('Erro ao registrar Service Worker:', error);
			});
	});
}

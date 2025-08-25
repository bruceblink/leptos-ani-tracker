use leptos::prelude::{ClassAttribute, ElementChild};
use leptos::{component, view, IntoView};

/// Renders the home page of your application.
#[component]
pub fn Navbar() -> impl IntoView {
    view! {
        <div class="header">
            <div class="navbar">
                <div class="navbar-left">
                     <nav class="nav-collapse">
                        <a href="/">"Home"</a>
                        <a href="/history">"History"</a>    
                        <a href="/about">"About"</a>
                    </nav>
                </div>
                <div class="navbar-right">
                </div>
            </div>
        </div>
    }
}
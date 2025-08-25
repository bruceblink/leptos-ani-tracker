use leptos::prelude::*;
use leptos_meta::{provide_meta_context, Stylesheet, Title};
use leptos_router::{
    components::{Route, Router, Routes},
    StaticSegment, WildcardSegment,
};
use crate::views::about_page::AboutPage;
use crate::views::history_page::HistoryPage;
use crate::views::home_page::HomePage;
use crate::views::navbar::Navbar;
use crate::views::not_found_page::NotFound;

#[component]
pub fn App() -> impl IntoView {
    // Provides context that manages stylesheets, titles, meta tags, etc.
    provide_meta_context();

    view! {
        // injects a stylesheet into the document <head>
        // id=leptos means cargo-leptos will hot-reload this stylesheet
        <Stylesheet id="leptos" href="/pkg/leptos-ani-tracker.css"/>

        // sets the document title
        <Title text="Welcome to Leptos"/>
        // navigation bar for all pages
        <Navbar/>
        // content for this welcome page
        <Router>
            <main class="main">
                <Routes fallback=move || "Not found.">
                    <Route path=StaticSegment("") view=HomePage/>
                    <Route path=StaticSegment("/history") view=HistoryPage/>
                    <Route path=StaticSegment("/about") view=AboutPage/>
                    <Route path=WildcardSegment("any") view=NotFound/>
                </Routes>
            </main>
        </Router>
    }
}
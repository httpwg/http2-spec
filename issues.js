function setStatus(msg) {
  let status = document.getElementById('status');
  status.innerText = msg;
}

function date(s) {
  const d = Date.parse(s);
  if (isNaN(d)) {
    return 0;
  }
  return d;
}

function stateString(issue) {
  let str;
  if (issue.pr) {
    switch (issue.state) {
      case 'MERGED':
      str = 'merged';
      break;
      case 'CLOSED':
      str = 'discarded';
      break;
      default:
      str = 'pr';
      break;
    }
  } else {
    str = issue.state.toLowerCase();
  }
  return str;
}

function stateOrder(issue) {
  return ['open', 'pr', 'closed', 'merged', 'discarded'].indexOf(stateString(issue));
}

var sortKey = 'id';
var sortInvert = false;
function invert(x) {
  return x * (sortInvert ? -1 : 1);
}
function sort(k) {
  sortInvert = (k === sortKey) ? !sortInvert : false;
  k = k || sortKey;
  let message = k;
  switch (k) {
    case 'id':
      subset.sort((x, y) => invert(x.number - y.number));
      message = 'ID';
      break;
    case 'recent':
      subset.sort((x, y) => invert(date(y.updatedAt) - date(x.updatedAt)));
      message = 'last modified';
      break;
    case 'closed':
      subset.sort((x, y) => invert(date(y.closedAt) - date(x.closedAt)));
      message = 'time of closure';
      break;
    case 'title':
      subset.sort((x, y) => invert(x.title.localeCompare(y.title)));
      break;
    case 'state':
      subset.sort((x, y) => invert(stateOrder(x) - stateOrder(y)));
      break;
    case 'author':
      subset.sort((x, y) => invert(x.author.localeCompare(y.author)));
    break;
      default:
      setStatus('no idea how to sort like that');
      return;
  }
  setStatus(`sorted by ${message}${(sortInvert) ? ' (reversed)' : ''}`);
  sortKey = k;
  list(subset);
}

function sortSetup() {
  ['id', 'title', 'state', 'author'].forEach(k => {
    let el = document.getElementById(`sort-${k}`);
    el.addEventListener('click', _ => sort(k));
    el.style.cursor = 'pointer';
    el.title = `Sort by ${el.innerText}`;
  });
}

var db;
async function get() {
  db = null;
  const response = await fetch('archive.json');
  if (Math.floor(response.status / 100) !== 2) {
    throw new Error(`Error loading <${url}>: ${response.status}`);
  }
  db = await response.json();
  db.pulls.forEach(pr => pr.pr = true);
  subset = db.all = db.issues.concat(db.pulls);
  db.labels = db.labels.reduce((all, l) => {
    all[l.name] = l;
    return all;
  }, {});
  sort();
  document.title = `${db.repo} Issues`;
  console.log(`Loaded ${db.all.length} issues for ${db.repo}.`);
  console.log('Raw data for issues can be found in:');
  console.log('  db.all = all issues and pull requests');
  console.log('  subset = just the subset of issues that are shown');
  console.log('format(subset[, formatter]) to dump the current subset to the console');
}

var issueFilters = {
  assigned: {
    args: ['string'],
    h: 'assigned to this user',
    f: login => issue => {
      if (login === '') {
        return issue.assignees.length > 0;
      } else {
        return issue.assignees.some(assignee => assignee === login);
      }
    },
  },

  author: {
    args: ['string'],
    h: 'created by this user',
    f: login => issue => issue.author === login,
  },

  commenter: {
    args: ['string'],
    h: 'commented on by this user',
    f: login => issue => {
      return issue.author === login ||
        issue.comments.some(comment => comment.author === login) ||
        (issue.reviews || []).some(review => review.author === login);
    },
  },

  reviewer: {
    args: ['string'],
    h: 'reviewed by this user',
    f: login => issue => {
      return issue.reviews &&
        issue.reviews.some(review => review.author === login);
    },
  },

  user: {
    args: ['string'],
    h: 'mentions this user',
    f: login => issue => {
      return issue.author === login ||
        issue.assignees.some(assignee => assignee === login) ||
        issue.comments.some(comment => comment.author === login) ||
        (issue.reviews || []).some(review => review.author === login);
    },
  },

  closed: {
    args: [],
    h: 'is closed',
    f: issue => issue.state === 'CLOSED',
  },

  open: {
    args: [],
    h: 'is open',
    f: issue => issue.state === 'OPEN',
  },

  merged: {
    args: [],
    h: 'a merged pull request',
    f: issue => issue.state == 'MERGED',
  },

  discarded: {
    args: [],
    h: 'a discarded pull request',
    f: issue => issue.pr && issue.state === 'CLOSED'
  },

  n: {
    args: ['integer'],
    h: 'issue by number',
    f: i => issue => issue.number === i,
  },

  label: {
    args: ['string'],
    h: 'has a specific label',
    f: name => issue => issue.labels.some(label => label === name),
  },

  labelled: {
    args: [],
    h: 'has any label',
    f: issue => issue.labels.length > 0,
  },

  title: {
    args: ['string'],
    h: 'search title with a regular expression',
    f: function(re) {
      re = new RegExp(re);
      return issue => issue.title.match(re);
    }
  },

  body: {
    args: ['string'],
    h: 'search body with a regular expression',
    f: function(re) {
      re = new RegExp(re);
      return issue => issue.body.match(re);
    }
  },

  text: {
    args: ['string'],
    h: 'search title and body with a regular expression',
    f: function(re) {
      re = new RegExp(re);
      return issue => issue.title.match(re) || issue.body.match(re);
    }
  },

  pr: {
    args: [],
    h: 'is a pull request',
    f: issue => issue.pr,
  },

  issue: {
    args: [],
    h: 'is a plain issue, i.e., not(pr)',
    f: function(issue) {
      return !issue.pr;
    }
  },

  or: {
    args: ['filter', '...filter'],
    h: 'union',
    f: (...filters) =>  x => filters.some(filter => filter(x)),
  },

  and: {
    args: ['filter', '...filter'],
    h: 'intersection',
    f: (...filters) => x => filters.every(filter => filter(x)),
  },


  xor: {
    args: ['filter', '...filter'],
    h: 'for the insane',
    f: (...filters) =>
      x => filters.slice(1).reduce((a, filter) => a ^ filter(x), filters[0](x)),
  },

  not: {
    args: ['filter'],
    h: 'exclusion',
    f: a => issue => !a(issue),
  },

  closed_since: {
    args: ['date'],
    h: 'issues closed since the date and time',
    f: since => issue => date(issue.closedAt) >= since,
  },

  updated_since: {
    args: ['date'],
    h: 'issues updated since the date and time',
    f: since => issue => date(issue.updatedAt) >= since,
  }
};

class Parser {
  constructor(s) {
    this.str = s;
    this.skipws();
  }

  skipws() {
    this.str = this.str.trimLeft();
  }

  jump(idx) {
    this.str = this.str.slice(idx);
    this.skipws();
  }

  get next() {
    return this.str.charAt(0);
  }

  parseName() {
    let m = this.str.match(/^[a-zA-Z](?:[a-zA-Z0-9_-]*[a-zA-Z0-9])?/);
    if (!m) {
      return;
    }

    this.jump(m[0].length);
    return m[0];
  }

  parseSeparator(separator) {
    if (this.next !== separator) {
      throw new Error(`Expecting separator ${separator}`);
    }
    this.jump(1);
  }

  parseString() {
    let end = -1;
    for (let i = 0; i < this.str.length; ++i) {
      let v = this.str.charAt(i);
      if (v === ')' || v === ',') {
        end = i;
        break;
      }
    }
    if (end < 0) {
      throw new Error(`Unterminated string`);
    }
    let s = this.str.slice(0, end).trim();
    this.jump(end);
    return s;
  }

  parseDate() {
    let str = this.parseString();
    let time = Date.parse(str);
    if (isNaN(time)) {
      throw new Error(`not a valid date: ${str}`);
    }
    return time;
  }

  parseNumber() {
    let m = this.str.match(/^\d+/);
    if (!m) {
      return;
    }
    this.jump(m[0].length);
    return parseInt(m[0], 10);
  }

  parseFilter() {
    if (this.next === '-') {
      this.parseSeparator('-');
      return issueFilters.not.f.call(null, this.parseFilter());
    }
    let name = this.parseName();
    if (!name) {
      let n = this.parseNumber();
      if (!isNaN(n)) {
        return issueFilters.n.f.call(null, n);
      }
      return;
    }
    let f = issueFilters[name];
    if (!f) {
      throw new Error(`Unknown filter: ${name}`);
    }
    if (f.args.length === 0) {
      return f.f;
    }
    let args = [];
    for (let i = 0; i < f.args.length; ++i) {
      let arg = f.args[i];
      let ellipsis = arg.slice(0, 3) === '...';
      if (ellipsis) {
        arg = arg.slice(3);
      }

      this.parseSeparator((i === 0) ? '(' : ',');
      if (arg === 'string') {
        args.push(this.parseString());
      } else if (arg === 'date') {
        args.push(this.parseDate());
      } else if (arg === 'integer') {
        args.push(this.parseNumber());
      } else if (arg === 'filter') {
        args.push(this.parseFilter());
      } else {
        throw new Error(`Error in filter ${name} definition`);
      }
      if (ellipsis && this.next === ',') {
        --i;
      }
    }
    this.parseSeparator(')');
    return f.f.apply(null, args);
  }
}

var subset = [];
function filterIssues(str) {
  subset = db.all;
  let parser = new Parser(str);
  let f = parser.parseFilter();
  while (f) {
    subset = subset.filter(f);
    f = parser.parseFilter();
  }
}

var formatter = {
  brief: x => `* ${x.title} (#${x.number})`,
  md: x => `* [#${x.number}](${x.url}): ${x.title}`,
};

function format(set, f) {
  return (set || subset).map(f || formatter.brief).join('\n');
}

var debounces = {};
var debounceSlowdown = 100;
function measureSlowdown() {
  let start = Date.now();
  window.setTimeout(_ => {
    let diff = Date.now() - start;
    if (diff > debounceSlowdown) {
      console.log(`slowed to ${diff} ms`);
      debounceSlowdown = Math.min(1000, diff + debounceSlowdown / 2);
    }
  }, 0);
}
function debounce(f) {
  let r = now => {
    measureSlowdown();
    f(now);
  };
  return e => {
    if (debounces[f.name]) {
      window.clearTimeout(debounces[f.name]);
      delete debounces[f.name];
    }
    if (e.key === 'Enter') {
      r(true);
    } else {
      debounces[f.name] = window.setTimeout(_ => {
        delete debounces[f.name];
        r(false)
      }, 10 + debounceSlowdown);
    }
  }
}

function cell(row, children, cellClass) {
  let td = document.createElement('td');
  if (cellClass) {
    td.className = cellClass;
  }
  if (Array.isArray(children)) {
    children.forEach(c => {
      td.appendChild(c);
      td.appendChild(document.createTextNode(' '));
    });
  } else {
    td.appendChild(children);
  }
  row.appendChild(td);
}


function loadAvatars(elements) {
  elements.forEach(e => {
    let avatar = new Image(16, 16);
    avatar.addEventListener('load', _ => e.target.replaceWith(avatar));
    let user = e.target.dataset.user;
    avatar.src = `https://github.com/${user}.png?size=16`;
  });
}
var intersection = new IntersectionObserver(loadAvatars, { rootMargin: '50px 0px 100px 0px' });

function author(x, click, userSearch) {
  let user = x.author || x;
  let sp = document.createElement('span');
  sp.classList.add('item', 'user');
  let ai = document.createElement('a');
  ai.href = `https://github.com/${user}`;
  ai.className = 'avatar';
  let placeholder = document.createElement('span');
  placeholder.className = 'swatch';
  placeholder.innerText = '\uD83E\uDDD0';
  placeholder.dataset.user = user;
  intersection.observe(placeholder);
  ai.appendChild(placeholder);
  sp.appendChild(ai);

  let au = document.createElement('a');
  au.href = `#${userSearch || 'user'}(${user})`;
  au.innerText = user;
  au.addEventListener('click', click);
  sp.appendChild(au);
  return sp;
}

function issueState(issue, click) {
  let st = document.createElement('span');
  st.classList.add('item', 'state');
  let a = document.createElement('a');
  a.innerText = stateString(issue);
  a.href = `#${stateString(issue)}`;
  if (click) {
    a.addEventListener('click', click);
  }
  st.appendChild(a);
  return st;
}

function showBody(item) {
  let div = document.createElement('div');
  div.className = 'body';
  let body = item.body.trim().replace(/\r\n?/g, '\n');

  let list = null;
  let el = null;
  let pre = null;
  function closeElement() {
    if (el) {
      if (list) {
        list.appendChild(el);
      } else {
        div.appendChild(el);
      }
    }
    el = null;
    pre = null;
  }
  function closeBoth() {
    closeElement();
    if (list) {
      div.appendChild(list);
      list = null;
    }
  }
  function addText(t) {
    if (pre) {
      el.appendChild(document.createTextNode(t + '\n'));
      return;
    }
    if (el.innerText !== '') {
      el.appendChild(document.createElement('br'));
    }
    if (t !== '') {
      el.appendChild(document.createTextNode(t));
    }
  }

  body.split('\n').forEach(t => {
    if (t.charAt(0) === ' ') {
      t = t.substring(1); // This fixes lots of problems.
    }
    if (t.indexOf('```') === 0) {
      let needNew = !el || !pre;
      closeBoth();
      if (needNew) {
        el = document.createElement('pre');
        pre = 'q';
        let language = t.substring(3).trim();
        if (language) {
          el.dataset.language = language;
        }
      }
    } else if (pre === 'q') {
      addText(t);
    } else if (!el && t.indexOf('   ') === 0) {
      if (!pre) {
        closeBoth();
        el = document.createElement('pre');
        pre = 's';
      }
      addText(t.substring(3));
    } else if (t.trim() === '') {
      closeElement();
    } else if (t.indexOf('# ') === 0) {
      closeBoth();
      el = document.createElement('h2');
      addText(t.substring(2).trimLeft());
      closeElement();
    } else if (t.indexOf('## ') === 0) {
      closeBoth();
      el = document.createElement('h3');
      addText(t.substring(3).trimLeft());
      closeElement();
    } else if (t.indexOf('### ') === 0) {
      closeBoth();
      el = document.createElement('h4');
      addText(t.substring(4).trimLeft());
      closeElement();
    } else if (t.charAt(0) === '>') {
      if (!el || el.tagName !== 'BLOCKQUOTE') {
        closeElement();
        el = document.createElement('blockquote');
      }
      addText(t.substring(1).trimLeft());
    } else if (t.indexOf('* ') === 0 || t.indexOf('- ') === 0) {
      if (list && list.tagName !== 'UL') {
        closeBoth();
      } else {
        closeElement();
      }
      if (!list) {
        list = document.createElement('ul');
      }
      el = document.createElement('li');
      addText(t.substring(2).trimLeft());
    } else if (t.match(/^(?:\(?\d+\)|\d+\.)/)) {
      if (list && list.tagName !== 'OL') {
        closeBoth();
      } else {
        closeElement();
      }
      if (!list) {
        list = document.createElement('ol');
      }
      el = document.createElement('li');
      let sep = t.match(/^(?:\(?\d+\)|\d+\.)/)[0].length;
      addText(t.substring(sep).trimLeft());
    } else {
      if (list && !el) {
        div.appendChild(list);
        list = null;
      }
      if (!el) {
        el = document.createElement('p');
      }
      addText(t);
    }
  });
  closeBoth();
  return div;
}

function showDate(d, reference) {
  let de = document.createElement('span');
  de.classList.add('item', 'date');
  const full = d.toISOString();
  const parts = full.split(/[TZ\.]/);
  if (reference && parts[0] === reference.toISOString().split('T')[0]) {
    de.innerText = parts[1];
  } else {
    de.innerText = parts[0] + ' ' + parts[1];
  }
  de.title = full;
  return de;
}

function narrow(e, extra) {
  e.preventDefault();
  hideIssue();
  let cmd = document.getElementById('cmd');
  let v = `${cmd.value} ${extra}`;
  cmd.value = v.trim();
  redraw(true);
}

function narrowLabel(e) {
  narrow(e, `label(${e.target.innerText})`);
}

function narrowState(e) {
  narrow(e, e.target.innerText);
}

function narrowUser(userType) {
  return function narrowUserInner(e) {
    narrow(e, `${userType}(${e.target.innerText})`);
  };
}

function showLabels(labels, click) {
  return labels.map(label => {
    let item = document.createElement('span');
    item.className = 'item';
    let sp = document.createElement('span');
    sp.className = 'swatch';
    item.appendChild(sp);
    let a = document.createElement('a');
    a.innerText = label;
    a.href = `#label(${label})`;
    if (click) {
      a.addEventListener('click', click);
    }
    if (db.labels.hasOwnProperty(label)) {
      sp.style.backgroundColor = '#' + db.labels[label].color;
      if (db.labels[label].description) {
        item.title = db.labels[label].description;
      }
    }
    item.appendChild(a);
    return item;
  });
}

// Make a fresh replacement element for the identified element.
function freshReplacement(id) {
  let e = document.getElementById(id);
  let r = document.createElement(e.tagName);
  r.id = id;
  e.replaceWith(r);
  return r;
}

var displayed = null;

function show(index) {
  if (index < 0 || index >= subset.length) {
    hideIssue();
    return;
  }
  displayed = index;
  const issue = subset[index];

  document.getElementById('overlay').classList.add('active');
  let frame = freshReplacement('issue');
  frame.classList.add('active');

  function showTitle() {
    let title = document.createElement('h2');
    title.className = 'title';
    let number = document.createElement('a');
    number.className = 'number';
    number.href = issue.url;
    number.innerText = `#${issue.number}`;
    title.appendChild(number);
    title.appendChild(document.createTextNode(': '));
    let name = document.createElement('a');
    name.href = issue.url;
    name.innerText = issue.title;
    title.appendChild(name);
    return title;
  }

  function showIssueLabels() {
    let meta = document.createElement('div');
    meta.className = 'meta';
    showLabels(issue.labels, hideIssue).forEach(el => {
      meta.appendChild(el);
      meta.appendChild(document.createTextNode(' '));
    });
    return meta;
  }

  function showIssueUsers() {
    let meta = document.createElement('div');
    meta.className = 'meta';
    meta.appendChild(author(issue, hideIssue, 'author'));
    if (issue.assignees && issue.assignees.length > 0) {
      let arrow = document.createElement('span');
      arrow.innerText = ' \u279c';
      arrow.title = 'Assigned to';
      meta.appendChild(arrow);
      issue.assignees.map(u => author(u, hideIssue, 'assigned')).forEach(el => {
        meta.appendChild(document.createTextNode(' '));
        meta.appendChild(el);
      });
    }
    return meta;
  }

  function showIssueDates() {
    let meta = document.createElement('div');
    meta.className = 'meta';
    let created = new Date(issue.createdAt);
    meta.appendChild(showDate(created));
    meta.appendChild(issueState(issue, hideIssue));
    if (issue.closedAt) {
      meta.appendChild(showDate(new Date(issue.closedAt), created));
    }
    return meta;
  }

  let refdate = null;
  function showComment(c) {
    let row = document.createElement('tr');
    let cdate = new Date(c.createdAt);
    cell(row, showDate(cdate, refdate), 'date');
    refdate = cdate;
    cell(row, author(c, hideIssue, (c.commit) ? 'reviewer' : 'commenter'), 'user');

    if (issue.pr) {
      let icon = document.createElement('span');
      switch (c.state) {
        case 'APPROVED':
          icon.innerText = '\u2714';
          icon.title = 'Approved';
          break;
        case 'CHANGES_REQUESTED':
          icon.innerText = '\u2718';
          icon.title = 'Changes Requested';
          break;
        default:
          icon.innerText = '\uD83D\uDCAC';
          icon.title = 'Comment';
          break;
      }
      cell(row, icon);
    }

    let body = showBody(c);
    if (c.comments && c.comments.length > 0) {
      let codeComments = document.createElement('div');
      codeComments.className = 'item';
      const s = (c.comments.length === 1) ? '' : 's';
      codeComments.innerText = `... ${c.comments.length} comment${s} on changes`;
      body.appendChild(codeComments);
    }
    cell(row, body);
    return row;
  }

  frame.appendChild(showTitle());
  frame.appendChild(showIssueLabels());
  frame.appendChild(showIssueUsers());
  frame.appendChild(showIssueDates());
  frame.appendChild(showBody(issue));

  let allcomments = (issue.comments || []).concat(issue.reviews || []);
  allcomments.sort((a, b) => date(a.createdAt) - date(b.createdAt));
  let comments = document.createElement('table');
  comments.className = 'comments';
  allcomments.map(showComment).forEach(row => comments.appendChild(row));
  frame.appendChild(comments);

  frame.scroll(0, 0);
  frame.focus();
}

function hideIssue() {
  document.getElementById('help').classList.remove('active');
  document.getElementById('issue').classList.remove('active');
  document.getElementById('overlay').classList.remove('active');
  displayed = null;
}

function step(n) {
  if (displayed === null) {
    if (n > 0) {
      show(n - 1);
    } else {
      show(subset.length + n);
    }
  } else {
    show(displayed + n);
  }
}

function makeRow(issue, index) {
  function cellID() {
    let a = document.createElement('a');
    a.innerText = issue.number;
    a.href = issue.url;
    a.onclick = e => {
      e.preventDefault();
      show(index);
    };
    return a;
  }

  function cellTitle() {
    let a = document.createElement('a');
    a.innerText = issue.title;
    a.href = issue.url;
    a.onclick = e => {
      e.preventDefault();
      show(index);
    };
    return a;
  }

  let tr = document.createElement('tr');
  cell(tr, cellID(), 'id');
  cell(tr, cellTitle(), 'title');
  cell(tr, issueState(issue, narrowState), 'state');
  cell(tr, author(issue, narrowUser('author'), 'author'), 'user');
  cell(tr, (issue.assignees || [])
             .map(u => author(u, narrowUser('assigned'), 'assigned')), 'assignees');
  cell(tr, showLabels(issue.labels, narrowLabel), 'labels');
  return tr;
}

function list(issues) {
  if (!issues) {
    return;
  }

  let body = freshReplacement('issuelist');
  body.innerHTML = '';
  issues.forEach((issue, index) => {
    body.appendChild(makeRow(issue, index));
  });
}

var currentFilter = '';
function filter(str, now) {
  try {
    filterIssues(str);
    setStatus(`${subset.length} records selected`);
    if (now) {
      window.location.hash = str;
      currentFilter = str;
    }
  } catch (e) {
    if (now) { // Only show errors when someone hits enter.
      setStatus(`Error: ${e.message}`);
      console.log(e);
    }
  }
}

function showHelp() {
  setStatus('help shown');
  let h = document.getElementById('help');
  h.classList.add('active');
  h.scroll(0, 0);
  h.focus();
  document.getElementById('overlay').classList.add('active');
}

function slashCmd(cmd) {
  if (cmd[0] === 'help') {
    document.getElementById('cmd').blur();
    showHelp();
  } else {
    setStatus('unknown command: /' + cmd.join(' '));
  }
}

function redraw(now) {
  let cmd = document.getElementById('cmd');
  if (cmd.value.charAt(0) == '/') {
    if (now) {
      slashCmd(cmd.value.slice(1).split(' ').map(x => x.trim()));
      cmd.value = currentFilter;
    }
    return;
  }

  if (!db) {
    if (now) {
      showStatus('Still loading...');
    }
    return;
  }

  document.getElementById('help').classList.remove('active');
  filter(cmd.value, now);
  list(subset);
}

function generateHelp() {
  let functionhelp = document.getElementById('functions');
  Object.keys(issueFilters).forEach(k => {
    let li = document.createElement('li');
    let arglist = '';
    if (issueFilters[k].args.length > 0) {
      arglist = '(' + issueFilters[k].args.map(x => '<' + x + '>').join(', ') + ')';
    }
    let fn = document.createElement('tt');
    fn.innerText = k + arglist;
    li.appendChild(fn);
    let help = '';
    if (issueFilters[k].h) {
      help = ' - ' + issueFilters[k].h;
    }
    li.appendChild(document.createTextNode(help));
    functionhelp.appendChild(li);
  });
}

function addFileHelp() {
  setStatus('error loading file');
  if (window.location.protocol !== 'file:') {
    return;
  }
  let p = document.createElement('p');
  p.className = 'warning';
  p.innerHTML = 'Important: Browsers display files inconsistently.' +
    ' You can work around this by running an HTTP server,' +
    ' such as <code>python3 -m http.server</code>,' +
    ' then view this file using that server.';
  document.getElementById('help').insertBefore(p, h.firstChild);
}

function issueOverlaySetup() {
  let overlay = document.getElementById('overlay');
  overlay.addEventListener('click', hideIssue);
  window.addEventListener('keyup', e => {
    if (e.target.id === 'cmd') {
      if (e.key === 'Escape') {
        e.preventDefault();
        e.target.blur();
      }
      return;
    }
    if (e.key === 'Escape') {
      e.preventDefault();
      hideIssue();
    }
  });
  window.addEventListener('keypress', e => {
    if (e.target.closest('input')) {
      return;
    }
    if (e.key === 'p' || e.key === 'k') {
      e.preventDefault();
      step(-1);
    } else if (e.key === 'n' || e.key === 'j') {
      e.preventDefault();
      step(1);
    } else if (e.key === '?') {
      e.preventDefault();
      showHelp();
    } else if (e.key === '\'') {
      e.preventDefault();
      hideIssue();
      document.getElementById('cmd').focus();
    } else if (e.key === 'c') {
      e.preventDefault();
      hideIssue();
      document.getElementById('cmd').value = '';
      redraw(true);
    }
  })
}

window.onload = () => {
  let cmd = document.getElementById('cmd');
  let redrawHandler = debounce(redraw);
  cmd.addEventListener('input', redrawHandler);
  cmd.addEventListener('keypress', redrawHandler);
  window.addEventListener('hashchange', e => {
    cmd.value = decodeURIComponent(window.location.hash.substring(1));
    redrawHandler(e);
  });
  if (window.location.hash) {
    cmd.value = decodeURIComponent(window.location.hash.substring(1));
  }
  sortSetup();
  generateHelp();
  issueOverlaySetup();
  get().then(redraw).catch(addFileHelp);
}

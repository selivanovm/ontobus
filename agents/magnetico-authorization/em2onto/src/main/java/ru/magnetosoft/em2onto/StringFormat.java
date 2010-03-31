package ru.magnetosoft.em2onto;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author SheringaA
 */
public class StringFormat {
	public static final char[] hex = { '0', '1', '2', '3', '4', '5', '6', '7',
			'8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	public static final char[] heX = { '0', '1', '2', '3', '4', '5', '6', '7',
			'8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
	public static int[] dehex = new int[256];

	static {
		for (int i = 0; i < 256; i++) {
			dehex[i] = -1;
		} // end for

		for (int i = 0; i < 16; i++) {
			dehex[(hex[i] & 0xFF)] = i;
			dehex[(heX[i] & 0xFF)] = i;
		} // end for
	}

	public static final char[] paragraph = { '<', '/', 'p', '>', '<', 'p', '>' };
	public static final char[] escape_lt = { '&', 'l', 't', ';' };
	public static final char[] escape_gt = { '&', 'g', 't', ';' };
	public static final char[] escape_amp = { '&', 'a', 'm', 'p', ';' };
	public static final char[] escape_quot = { '&', 'q', 'u', 'o', 't', ';' };

	/**
	 * Decode unicode-URL string to ordinary.
	 * <p>
	 * Sequences "<b>%XX</b>" are converted to XX (hexadeciamal) chars (base
	 * charset).
	 * </p>
	 * <p>
	 * Sequences "<b>%uXXXX</b>" are converted to XXXX (hexadeciamal) chars
	 * (extended charset).
	 * </p>
	 * <p>
	 * In case X is not a hexadecimal digit - output char is unpredictable.
	 * </p>
	 * 
	 * @param input
	 * @return empty string if input is <b>null</b>, substituted string
	 *         otherwise.
	 */
	public static String getString4URL(String input) {
		if (input == null) {
			return "";
		} // end if

		char[] inp = input.toCharArray();
		int i = 0;
		int l = inp.length;
		StringBuilder out = new StringBuilder(l);

		while (i < l) {
			char c = inp[i];
			i++;

			if (c != '%') {
				out.append(c);
			} // end if
			else {
				c = inp[i];
				i++;

				if (c == 'u') {
					int l1 = dehex[inp[i] & 0xFF];
					i++;

					int l2 = dehex[inp[i] & 0xFF];
					i++;

					int l3 = dehex[inp[i] & 0xFF];
					i++;

					int l4 = dehex[inp[i] & 0xFF];
					i++;
					out
							.append((char) ((l1 << 12) | (l2 << 8) | (l3 << 4) | l4));
				} // end if
				else {
					int l1 = dehex[c & 0xFF];
					int l2 = dehex[inp[i] & 0xFF];
					i++;
					out.append((char) ((l1 << 4) | l2));
				} // end else
			} // end else
		} // end while

		return out.toString();
	} // end getString4URL()

	/**
	 * Encode ordinary string to unicode-URL.
	 * <p>
	 * <b>[0-9,a-z,A-Z]</b> chars remains.
	 * </p>
	 * <p>
	 * Chars from base charset (0-255) are converted to "<b>%XX</>"
	 * (hexadeciamal).
	 * </p>
	 * <p>
	 * Chars from extended charset (>255) are converted to "<b>%uXXXX</b>"
	 * (hexadeciamal).
	 * </p>
	 * 
	 * @param input
	 * @return empty string if input is <b>null</b>, substituted string
	 *         otherwise.
	 */
	public static String getURLfromString(String input) {
		if (input == null) {
			return "";
		} // end if

		char[] inp = input.toCharArray();
		int i;
		int l = inp.length;
		StringBuilder out = new StringBuilder(l);

		for (i = 0; i < l; i++) {
			char c = inp[i];

			// TODO remake it!
			if (((c >= 'a') && (c <= 'z')) || ((c >= 'A') && (c <= 'Z'))
					|| ((c >= '0') && (c <= '9'))) {
				out.append(c);
			} // end if
			else {
				out.append('%');

				if ((c & 0xFFFF) >= 0x100) {
					out.append('u');

					int l1 = (c >> 8) & 0xF;
					int l2 = (c >> 12) & 0xF;
					out.append(hex[l2]);
					out.append(hex[l1]);
				} // end if

				int l1 = c & 0xF;
				int l2 = (c >> 4) & 0xF;
				out.append(hex[l2]);
				out.append(hex[l1]);
			} // end else
		} // end for

		return out.toString();
	} // end getURLfromString()

	/**
	 * Substitute "<b>\n</b>" char with "<b>&lt;/p&gt;&lt;p&gt;</b>"
	 * 
	 * @param input
	 * @return empty string if input is <b>null</b>, substituted string
	 *         otherwise.
	 */
	public static String getString4HTML(String input) {
		if (input == null) {
			return "";
		} // end if

		char[] inp = input.toCharArray();
		int l = inp.length;
		int s = paragraph.length;
		StringBuilder out = new StringBuilder(l);

		for (int i = 0; i < l; i++) {
			char c = inp[i];

			if (c != 10) {
				out.append(c);
			} // end if
			else {
				out.append(paragraph);
			} // end else
		} // end for

		return "<p>" + out.toString() + "</p>";
	} // end getString4HTML()

	public static String getString4BR(String input) {
		if (input == null) {
			return "";
		} // end if

		char[] inp = input.toCharArray();
		int l = inp.length;
		int s = paragraph.length;
		StringBuilder out = new StringBuilder(l);

		for (int i = 0; i < l; i++) {
			char c = inp[i];

			if (c != 10) {
				out.append(c);
			} // end if
			else {
				// out.append("\\x0A\\x0D");
				out.append("\n");
			} // end else
		} // end for

		return out.toString();
	} // end getString4HTML()

	/**
	 * Substitute unsafe chars with escape sequences, namely:
	 * <ul>
	 * <li>"<b>&gt;</b>" with "<b>&amp;gt;</b>"</li>
	 * <li>"<b>&lt;</b>" with "<b>&amp;lt;</b>"</li>
	 * <li>"<b>&quot;</b>" with "<b>&amp;quot;</b>"</li>
	 * <li>"<b>'</b>" with "<b>&amp;quot;</b>"</li>
	 * <li>"<b>&amp;</b>" with "<b>&amp;amp;</b>"</li>
	 * </ul>
	 * 
	 * @param input
	 * @return empty string if input is <b>null</b>, substituted string
	 *         otherwise.
	 */
	public static String getString4TextField(String input) {
		if (input == null) {
			return "";
		} // end if

		char[] inp = input.toCharArray();
		int l = inp.length;
		int s = paragraph.length;
		StringBuilder out = new StringBuilder(l);

		for (int i = 0; i < l; i++) {
			char c = inp[i];

			if (c == '>') {
				out.append(escape_gt);
			} // end if
			else if (c == '<') {
				out.append(escape_lt);
			} // end else if
			else if (c == '&') {
				out.append(escape_amp);
			} // end else if
			else if (c == '"') {
				out.append(escape_quot);
			} // end else if
			else if (c == '\'') {
				out.append(escape_quot);
			} // end else if
			else {
				out.append(c);
			} // end else
		} // end for

		return out.toString();
	} // end getString4TextField()

	public static String getString4TextFieldBack(String input) {
		if (input == null) {
			return "";
		} // end if

		StringBuilder out = new StringBuilder();
		char[] buf = input.toCharArray();
		int k = buf.length;
		int i = 0;

		while (i < k) {
			char c1 = buf[i];
			i++;

			if (c1 != '&') {
				out.append(c1);
			} // end if
			else {
				if (i + 2 < k) {
					char c2 = buf[i];
					i++;

					if (c2 == 'q') {
						if (i + 3 < k) {
							if ((buf[i] == 'u') && (buf[i + 1] == 'o')
									&& (buf[i + 2] == 't')
									&& (buf[i + 3] == ';')) {
								i += 4;
								out.append('"');
							} // end if
							else {
								out.append('&');
								out.append(c2);
							} // end else
						} // end if
						else {
							out.append('&');
							out.append(c2);
						} // end else
					} // end if
					else if (c2 == 't') {
						if (i + 4 < k) {
							if ((buf[i] == 'i') && (buf[i + 1] == 'l')
									&& (buf[i + 2] == 'd')
									&& (buf[i + 3] == 'e')
									&& (buf[i + 4] == ';')) {
								i += 5;
								out.append('~');
							} // end if
							else {
								out.append('&');
								out.append(c2);
							} // end else
						} // end if
						else {
							out.append('&');
							out.append(c2);
						} // end else
					} // end else if
					else if (c2 == 'a') {
						if (i + 2 < k) {
							char c3 = buf[i];
							i++;

							if (c3 == 'm') {
								if (i + 1 < k) {
									if ((buf[i] == 'p') && (buf[i + 1] == ';')) {
										i += 2;
										out.append('&');
									} // end if
									else {
										out.append('&');
										out.append(c2);
										out.append(c3);
									} // end else
								} // end if
								else {
									out.append('&');
									out.append(c2);
									out.append(c3);
								} // end else
							} // end if
							else if (c3 == 'p') {
								if (i + 2 < k) {
									if ((buf[i] == 'o') && (buf[i + 1] == 's')
											&& (buf[i + 2] == ';')) {
										i += 3;
										out.append('\'');
									} // end if
									else {
										out.append('&');
										out.append(c2);
										out.append(c3);
									} // end else
								} // end if
								else {
									out.append('&');
									out.append(c2);
									out.append(c3);
								} // end else
							} // end else if
							else {
								out.append('&');
								out.append(c2);
								out.append(c3);
							} // end else
						} // end if
						else {
							out.append('&');
							out.append(c2);
						} // end else
					} // end else if
					else if (c2 == 'l') {
						if (i + 1 < k) {
							if ((buf[i] == 't') && (buf[i + 1] == ';')) {
								i += 2;
								out.append('<');
							} // end if
							else {
								out.append('&');
								out.append(c2);
							} // end else
						} // end if
						else {
							out.append('&');
							out.append(c2);
						} // end else
					} // end else if
					else if (c2 == 'g') {
						if (i + 1 < k) {
							if ((buf[i] == 't') && (buf[i + 1] == ';')) {
								i += 2;
								out.append('>');
							} // end if
							else {
								out.append('&');
								out.append(c2);
							} // end else
						} // end if
						else {
							out.append('&');
							out.append(c2);
						} // end else
					} // end else if
					else {
						out.append('&');
						out.append(c2);
					} // end else
				} // end if
				else {
					out.append('&');
				} // end else
			} // end else
		} // end while

		return out.toString();
	} // end getString4TextFieldBack()

	/**
	 * Splits input string to tokens according to split char and place them into
	 * list.
	 * 
	 * @param input
	 *            input string
	 * @param split
	 *            split char
	 * @return empty string if input is <b>null</b>, substituted string
	 *         otherwise.
	 */
	public static List<String> string2List(String input, char split) {
		List<String> ret = new ArrayList<String>();
		if (input == null) {
			return ret;
		}
		char[] str = input.toCharArray();
		int l = str.length;

		char[] sub = new char[l];
		int i = 0, lsub = 0;

		while (i < l) {
			if (str[i] == split) {
				if (lsub > 0) {
					ret.add(new String(sub, 0, lsub));
					lsub = 0;
				}
			} // end if
			else {
				sub[lsub] = str[i];
				lsub++;
			} // end else

			i++;
		} // end while

		if (lsub > 0) {
			ret.add(new String(sub, 0, lsub));
		} // end if

		return ret;
	} // end string2List()
} // end StringFormat
